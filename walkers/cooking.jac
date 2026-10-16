"""Traverse the active recipe's steps and apply deterministic session transitions."""
import from graph.models {
    CookingSession,
    Recipe,
    RecipeStep,
    SESSION_RECIPE,
    HAS_STEP,
    CURRENT_STEP,
    COMPLETED_STEP
}
import from cooking.views { CookingView }

walker CookingWalker {
    has action: str = "resume",
        steps: list[RecipeStep] = [],
        sequences: dict[str, int] = {},
        recipe_name: str = "",
        result: CookingView | None = None,
        reports: list[CookingView] = [];

    can begin with CookingSession entry {
        if self.action not in ["start", "resume", "next", "back", "restart"] {
            raise ValueError("Unknown cooking action.");
        }
        visit [here->:SESSION_RECIPE:->];
    }

    can recipe with Recipe entry {
        self.recipe_name = here.name;
        for step in [here->:HAS_STEP:->] {
            for relation in [edge here->:HAS_STEP:->step] {
                self.sequences[jid(step)] = relation.sequence;
            }
        }
        visit [here->:HAS_STEP:->];
    }

    can step with RecipeStep entry {
        self.steps.append(here);
    }

    can finish with CookingSession exit {
        self.steps.sort(key=lambda (step: RecipeStep) { self.sequences[jid(step)]; });
        current_nodes = [here->:CURRENT_STEP:->];
        if len(current_nodes) != 1 or not self.steps {
            raise ValueError("Session must reference one current recipe step.");
        }
        if jid(current_nodes[0]) not in self.sequences {
            raise ValueError("Current step does not belong to this recipe.");
        }
        current = self.sequences[jid(current_nodes[0])];
        if self.action in ["start", "restart"] {
            current = 1;
            here.finished = False;
        } elif self.action == "next" and not here.finished {
            if current < len(self.steps) {
                current += 1;
            } else {
                here.finished = True;
            }
        } elif self.action == "back" {
            if here.finished {
                here.finished = False;
            } elif current > 1 {
                current -= 1;
            }
        }
        del [edge here->:CURRENT_STEP:->];
        del [edge here->:COMPLETED_STEP:->];
        here +>:CURRENT_STEP():+> self.steps[current - 1];
        for step in self.steps {
            if self.sequences[jid(step)] < current or here.finished {
                here +>:COMPLETED_STEP():+> step;
            }
        }
        completed = [self.sequences[jid(step)] for step in [here->:COMPLETED_STEP:->]];
        completed.sort();
        self.result = CookingView(
            recipe_key=here.recipe_key,
            recipe_name=self.recipe_name,
            current_sequence=current,
            total_steps=len(self.steps),
            completed=completed,
            finished=here.finished,
            instruction=self.steps[current - 1].instruction
        );
        report self.result as CookingView;
    }
}
