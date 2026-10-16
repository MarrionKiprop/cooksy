"""Graph-first proposals. Model output never determines scores or topology directly."""
import from graph.models { CulinaryCatalogue, Recipe, CATALOGUE_RECIPE }
import from graph.projections { recipe_view }
import from ai.models { RecipeCandidate, HAS_CANDIDATE }
import from ai.views { CandidateView, EnrichmentResult }
import from ai.memory { identity, valid_candidate, insert_candidate, candidate_view }
import ai.provider as provider;

walker EnrichmentWalker {
    has cache: CulinaryCatalogue,
        pantry: list[str],
        cuisine: str;

    has coverage_score: int = 0;
    has candidates: list[CandidateView] = [],
        known: set[str] = set(),
        known_names: list[str] = [],
        events: list[str] = [],
        status: str = "graph",
        message: str = "Reused graph content; no model call.";

    can begin with CulinaryCatalogue entry {
        self.events.append(
            "Consulted existing recipe graph and culinary candidate memory."
        );
        visit [here->:CATALOGUE_RECIPE:->];
        visit [self.cache->:HAS_CANDIDATE:->];
    }

    can recipe with Recipe entry {
        view = recipe_view(here);
        self.known.add(identity(view.name, view.tradition));
        self.known_names.append(view.name);
        if self.accepts(view.region, view.tradition) {
            required = [
                item.name
                for item in view.requirements
                if item.essential
            ];
            missing = [
                name
                for name in required
                if name not in self.pantry
            ];
            self.candidates.append(
                CandidateView(
                    key=view.key,
                    name=view.name,
                    description=view.description,
                    region=view.region,
                    tradition=view.tradition,
                    minutes=view.minutes,
                    score=(100 * (len(required) - len(missing))) // len(required)
                        if required
                        else 100,
                    missing=missing,
                    provenance=view.provenance,
                    verification=view.verification,
                    prepared=True
                )
            );
        }
    }

    can candidate with RecipeCandidate entry {
        self.known.add(here.key);
        self.known_names.append(here.name);
        if self.accepts(here.region, here.tradition)
            and not any([item.key == here.key for item in self.candidates]) {
            self.candidates.append(candidate_view(here, self.pantry));
        }
    }

    def accepts(region: str, tradition: str) -> bool {
        return not self.cuisine
            or self.cuisine.lower() in (region + " " + tradition).lower();
    }

    can finish with CulinaryCatalogue exit {
        if len(
            [
                item
                for item in self.candidates
                if item.score >= self.coverage_score
            ]
        )
            < 5 {
            if not provider.enabled() {
                self.status = "unavailable";
                self.message = "AI is not configured or is disabled. Existing graph results remain available.";
            } elif len([self.cache->:HAS_CANDIDATE:->]) >= 100 {
                self.status = "limited";
                self.message = "The process cache is full. Browse existing dishes; restarting clears generated content.";
            } else {
                try {
                    self.events.append(
                        "Coverage below five qualifying candidates; requested structured proposals."
                    );
                    batch = provider.propose(
                        self.pantry, self.cuisine, self.known_names
                    );
                    if len(batch.candidates) > 5 {
                        raise ValueError("Too many candidates");
                    }
                    accepted: int = 0;
                    rejected: int = 0;
                    for draft in batch.candidates {
                        key = identity(draft.name, draft.tradition);
                        if not valid_candidate(draft)
                            or key in self.known
                            or not self.accepts(draft.region, draft.tradition) {
                            rejected += 1;
                            continue;
                        }
                        if len([self.cache->:HAS_CANDIDATE:->]) >= 100 {
                            break;
                        }
                        candidate = insert_candidate(
                            self.cache,
                            draft,
                            "OpenAI gpt-4.1-mini · structured culinary proposal"
                        );
                        self.known.add(key);
                        self.candidates.append(candidate_view(candidate, self.pantry));
                        accepted += 1;
                    }
                    self.status = "enriched" if accepted else "no_new_candidates";
                    self.message = str(accepted)
                        + " new AI candidates; "
                        + str(rejected)
                        + " invalid, duplicate or out-of-scope proposals skipped. Needs verification.";
                    self.events.append(
                        "Validated output and created "
                            + str(accepted)
                            + " candidate nodes with ingredient relationships."
                    );
                } except Exception {
                    self.status = "unavailable";
                    self.message = "AI could not return valid candidates. Existing graph results are preserved. Try again later.";
                    self.events.append(
                        "Provider failed or output was malformed; graph fallback preserved."
                    );
                }
            }
        }
        self.candidates.sort(
            key=lambda (item: CandidateView) { (
                len(item.missing),
                -item.score,
                item.minutes,
                item.key
            ); }
        );
        report EnrichmentResult(
            candidates=self.candidates[:5],
            status=self.status,
            message=self.message,
            events=self.events
        );
    }
}
