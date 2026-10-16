You are the implementation lead for **Cooksy**, a polished Jac-native culinary discovery and cook-along web application. Build it in this repository incrementally and persistently. Do not try to complete the whole product in one pass.

## Core outcome

Cooksy helps a user:

1. Enter pantry ingredients by text or confirm ingredients suggested from an uploaded photo.
2. Explore cuisines and regions.
3. Discover recipe candidates based on their pantry.
4. See exactly which ingredients are available, missing, optional, or substitutable.
5. Open a recipe with ingredients, steps, cultural context, nutrition estimates, and an explicitly labelled AI-generated serving preview.
6. Use a focused cook-along mode with progress and timers.

The product must demonstrate genuine Jac object-spatial programming:

- Real Jac nodes, edges, and walkers—not JSON records renamed as graph concepts.
- A traversable culinary graph with recipes, ingredients, regions, traditions, steps, user pantry, cooking sessions, vision detections, nutrition data, and generated images.
- Jac `by llm()` used for structured culinary enrichment and contextual cooking assistance.
- Deterministic graph traversal and matching for recipe availability/ranking; do not ask an LLM to do simple filtering or arithmetic.
- Python only where specialised ML inference is justified: MobileNet for ingredient-image suggestions and SDXL for recipe-grounded serving previews.
- A polished, responsive, accessible UI.

## Non-negotiable operating rules

1. Start by inspecting the repository and running `jac guide`. Treat the installed `jac` binary and `jac guide` output as the authoritative source for Jac syntax, project structure, testing, client components, importing Python, graph persistence, and `by llm()`.

2. Do not invent Jac syntax from memory. Before introducing a Jac feature, query the relevant topic with `jac guide` and record the verified pattern in `docs/DECISIONS.md`.

3. Work in small, sequential milestones. Complete only one milestone at a time. A milestone is complete only after its acceptance checks pass, progress documents are updated, and the work is committed to Git.

4. At the beginning of every session, read these files before changing code:

   - `AGENTS.md`
   - `docs/PROGRESS.md`
   - `docs/DECISIONS.md`
   - `NEXT_SESSION.md`
   - latest Git log and working-tree status

5. At the end of every milestone, update all recovery files, run the applicable checks, and create a focused Git commit. If interrupted by context/token limits, stop cleanly after updating `NEXT_SESSION.md`; never leave the project state ambiguous.

6. Do not claim an integration works unless it has been exercised with a test, mock, or a real configured provider. If credentials, a GPU, network access, or model weights are unavailable, implement a clean adapter contract plus deterministic demo/mock mode, visibly disclose the limitation in the UI, and document the exact activation steps.

7. Never hard-code secrets. Use environment variables and provide `.env.example`.

8. Preserve existing user work. Inspect before editing. Do not use destructive Git commands.

## First deliverables: persistent project memory

Before implementing app features, create or improve:

- `AGENTS.md` — permanent operating instructions for future Codex sessions: architecture rules, verified Jac workflow, commands, test expectations, milestone discipline, coding conventions, and recovery protocol.
- `docs/PROGRESS.md` — milestone table with status, scope, acceptance checks, commit hash, date, risks, and next action.
- `docs/DECISIONS.md` — numbered architecture decision log. Each decision includes context, decision, verified Jac evidence/command where applicable, alternatives, and consequence.
- `NEXT_SESSION.md` — concise restart brief: current milestone, current status, exact next action, commands to run, blockers, uncommitted files if any, and definition of done.
- `README.md` — project overview, local setup, Jac commands, model-provider configuration, demo-mode limitations, test commands, and architecture summary.
- `.env.example` — no real values; document required and optional variables.

Commit this as the project-recovery foundation before building substantial functionality.

## Product architecture

Use the current Jac installation’s verified patterns to implement the following model. Names may be adjusted only when required by actual Jac syntax, and any adjustment must be recorded in `docs/DECISIONS.md`.

### Core graph nodes

- `User` or session identity
- `Pantry`
- `Ingredient`
- `Region`
- `CulinaryTradition`
- `Recipe`
- `RecipeVariant`
- `RecipeStep`
- `IngredientImage`
- `DetectionResult`
- `NutritionProfile`
- `GeneratedImage`
- `CookingSession`

### Core graph edges

- `HAS_INGREDIENT`: Pantry → Ingredient; carries quantity, unit, optional notes.
- `REQUIRES`: Recipe → Ingredient; carries quantity, unit, essentiality, preparation state, substitution notes.
- `BELONGS_TO`: Recipe → CulinaryTradition.
- `PART_OF`: CulinaryTradition → Region.
- `VARIANT_OF`: RecipeVariant → Recipe.
- `HAS_STEP`: Recipe → RecipeStep; carries sequence/order.
- `HAS_IMAGE`: Recipe → GeneratedImage.
- `HAS_NUTRITION`: Recipe → NutritionProfile.
- `DETECTS`: IngredientImage → DetectionResult.
- `CONFIRMED_AS`: DetectionResult → Ingredient.
- `CURRENT_STEP`: CookingSession → RecipeStep.

### Required walkers

Implement these as real Jac walkers using verified syntax. Their contracts must be testable.

1. `IntakeWalker`
   - Accepts typed ingredients and user-confirmed vision suggestions.
   - Normalises names, removes duplicates, updates the pantry graph.
   - Does not silently treat classifier output as confirmed.

2. `DiscoveryWalker`
   - Traverses region → tradition → recipe relationships.
   - Retrieves existing graph candidates before enrichment.
   - Supports a selected region/tradition and an “all cuisines” route.

3. `EnrichmentWalker`
   - Uses Jac `by llm()` to request structured, schema-constrained recipe candidates only when graph coverage is insufficient.
   - Keeps provenance, status, and an explicit “AI-generated candidate / needs verification” state where appropriate.
   - Deduplicates before persistence.
   - Does not use LLM output as unquestioned nutrition or cultural fact.

4. `MatchingWalker`
   - Deterministically compares pantry contents against `REQUIRES` graph edges.
   - Calculates available, missing-essential, missing-optional, substitutions, and a transparent match score.
   - Explains why each recipe is ranked.

5. `RecipeWalker`
   - Assembles selected recipe data, ordered steps, quantities, context, substitutions, and links.

6. `NutritionWalker`
   - Computes per-serving estimates from a documented nutrition reference/dataset or clearly labelled demo data.
   - Discloses missing/uncertain inputs; never presents fabricated precision.

7. `VisualisationWalker`
   - Creates a recipe-grounded SDXL prompt only after recipe details are assembled.
   - Stores image URL/path, prompt, provider/model version, generation state, and timestamps.
   - Reuses cached generation where possible.
   - Labels every result “AI-generated serving preview; illustrative, not an exact photograph.”

8. `CookingWalker`
   - Creates and updates a cooking session.
   - Tracks current step and completed steps.
   - Supports timers where practical.
   - Uses `by llm()` only for contextual cooking help, with the active recipe/step supplied as grounded context.

## ML adapter requirements

### MobileNet ingredient-image adapter

Implement a thin Python adapter behind a stable interface. It must:

- Accept image input/reference.
- Validate file type/size and return safe errors.
- Preprocess and run a MobileNet-family model when configured.
- Return structured predictions: ingredient/label, confidence, model version, status, and `requires_user_confirmation: true`.
- Map raw labels cautiously; do not imply multi-object detection from a classifier.
- Provide a predictable demo mode when weights/dependencies are unavailable.
- Include tests for input validation, response shape, and the confirmation boundary.

Suggested response shape:

```json
{
  "model": "mobilenet_v3",
  "status": "predictions_available",
  "predictions": [
    { "ingredient": "potato", "confidence": 0.87 }
  ],
  "requires_user_confirmation": true
}
```

### SDXL serving-preview adapter

Implement a provider-neutral Python adapter with local/hosted configuration. It must:

- Accept a structured, recipe-grounded prompt request.
- Support configured real inference and predictable demo mode.
- Return structured generation state, image location, provider/model metadata, prompt, and errors.
- Cache by a stable recipe/prompt/version key.
- Never generate an image before a recipe has been selected.
- Include tests for prompt construction, cache behaviour, and unavailable-provider handling.

## UX and design requirements

Build a warm, modern food-product interface—not a generic developer dashboard.

Required screens/flows:

- Landing/explore page with region/tradition discovery.
- Pantry workspace with manual ingredient entry and photo upload.
- Vision prediction review where users can accept, edit, or reject each prediction.
- Recipe results with transparent pantry-match explanations.
- Recipe detail page: ingredients, available/missing status, substitutions, ordered steps, nutrition disclosure, cuisine context, and serving preview.
- Cook-along mode: one task at a time, visible step progress, back/next controls, timers where implemented, and contextual help.
- Empty, loading, retry, validation, offline/unconfigured-provider, and error states.
- Responsive layout for mobile and desktop.
- Accessible keyboard interaction, labelled controls, adequate contrast, and semantic structure.

Avoid deceptive UI: distinguish actual model output, demo data, generated images, pending verification, and unavailable functionality.

## Milestone plan

Do not skip ahead. Adapt implementation details to verified Jac capabilities, but retain the intent and acceptance criteria.

### M0 — Repository discovery and recovery system

- Inspect existing files, Git state, and installed Jac tooling.
- Run relevant `jac guide` queries.
- Create/update `AGENTS.md`, `README.md`, `.env.example`, `docs/PROGRESS.md`, `docs/DECISIONS.md`, and `NEXT_SESSION.md`.
- Establish the milestone checklist and initial architecture decisions.

Acceptance:
- Recovery documents exist and accurately describe the repo.
- Every Jac claim in docs is supported by a recorded `jac guide` query.
- Working tree is clean after a focused commit.

### M1 — Verified Jac application skeleton and polished shell

- Create the smallest runnable Jac-first full-stack app using only syntax verified by `jac guide`.
- Implement the application shell, navigation, responsive design system, and accessible basic pages.
- Add a visible development/demo status indicator.

Acceptance:
- App starts using documented commands.
- Core navigation works.
- Lint/type/test/build checks available for this stage pass.
- Screenshot or manual verification recorded in progress log.
- Commit.

### M2 — Object-spatial culinary graph seed

- Implement actual Jac nodes, edges, and seed traversal data.
- Seed at least two regions, multiple traditions, and enough recipes/ingredients/steps to demonstrate traversal.
- Implement `DiscoveryWalker` and a small graph-inspection test or route.

Acceptance:
- A test proves traversal across Region → Tradition → Recipe → Ingredient/Step.
- Recipe requirements are represented on graph relationships, not duplicated as isolated UI JSON.
- Commit.

### M3 — Pantry intake and deterministic matching

- Implement pantry UI and `IntakeWalker`.
- Implement `MatchingWalker` with clear score and missing-ingredient explanations.
- Add tests for normalisation, duplicate handling, essential vs optional ingredients, and ranking.

Acceptance:
- User can enter ingredients and receive ordered recipe matches.
- Matching is deterministic and traceable.
- Commit.

### M4 — Recipe detail and cook-along foundations

- Implement `RecipeWalker`, complete recipe detail view, and `CookingWalker`.
- Persist/maintain cooking session state using verified Jac patterns.
- Add progress controls and any implemented timers.

Acceptance:
- A user can select a recipe, begin cook-along, advance/reverse steps, and recover the current step.
- Commit.

### M5 — LLM enrichment and grounded assistance

- Verify the exact `by llm()` syntax and provider configuration through `jac guide`.
- Implement `EnrichmentWalker` with structured output validation, provenance, duplicate checks, and safe fallbacks.
- Add contextual cooking assistance grounded only in selected recipe/session information.
- Add tests/mocks for valid, malformed, duplicate, and unavailable LLM responses.

Acceptance:
- Existing graph content is consulted before enrichment.
- Generated candidates are clearly marked with provenance/verification state.
- No simple ranking/filtering is delegated to the LLM.
- Commit.

### M6 — MobileNet photo-to-confirmed-pantry flow

- Implement the adapter, upload flow, prediction review UI, and graph links for image/detections/confirmed ingredients.
- Add demo mode and user-facing disclosure if real inference is unavailable.

Acceptance:
- User must confirm/edit predictions before pantry mutation.
- Tests cover adapter contract and intake integration.
- Commit.

### M7 — SDXL preview flow

- Implement `VisualisationWalker`, provider-neutral SDXL adapter, caching, metadata storage, and recipe-page preview.
- Support demo mode without pretending it is a real generation.

Acceptance:
- A selected recipe produces or retrieves a recipe-grounded preview state.
- All previews carry the required illustrative AI label.
- Tests cover caching and error states.
- Commit.

### M8 — Nutrition, quality pass, and demo readiness

- Implement documented nutrition estimates and uncertainty disclosures.
- Complete responsive/accessibility/error-state polish.
- Run all tests and a full user journey.
- Verify setup from a clean environment as far as practical.
- Add demo script, known limitations, and architecture diagram/documentation.

Acceptance:
- Full manual flow works: pantry → discover → match → recipe → preview → cook along.
- Test suite passes.
- README makes setup, demo mode, providers, architecture, and limitations clear.
- Commit a final milestone checkpoint.

## Required engineering practices

- Prefer small cohesive modules and explicit contracts.
- Keep Jac as the source of application orchestration and object-spatial logic.
- Keep Python adapters small, isolated, typed where applicable, and independently testable.
- Use structured validation at all model boundaries.
- Never expose provider keys client-side.
- Add automated tests as each feature is built, not as a final task.
- Run relevant checks before every milestone commit.
- Record exact commands and their outcomes in `docs/PROGRESS.md`.
- If a command fails, diagnose and document the result; do not conceal failures.
- Make conventional, milestone-scoped commits such as `feat(graph): add culinary graph traversal`.
- Do not create unrelated refactors or replace working project tooling without a documented reason.

## Mandatory end-of-milestone handoff format

Before each commit, update `docs/PROGRESS.md` with:

- milestone identifier and status;
- files/features completed;
- commands run and pass/fail outcome;
- manual verification performed;
- known limitations and risks;
- commit hash after committing;
- exact next milestone.

Update `NEXT_SESSION.md` with:

- “Resume at: Mx”
- one-sentence current state;
- exact next implementation task;
- commands to run first;
- active blockers/configuration needs;
- definition of done for the next task.

Update `docs/DECISIONS.md` for any material technical choice, particularly Jac syntax/API patterns, graph persistence choices, LLM schema/provider choices, model adapter behaviour, and demo fallbacks.

Then commit. Do not start the next milestone until this handoff is complete.

## Start now

1. Inspect the repository and Git state.
2. Run `jac guide` and gather the minimum verified Jac guidance needed for M0 and M1.
3. Create the recovery/documentation foundation.
4. Implement only M0 unless M0 is already complete.
5. Report: current milestone, evidence of verification, files changed, checks run, commit hash, and the exact next step.