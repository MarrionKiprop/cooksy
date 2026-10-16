# Cooksy — Detailed Full-Stack Technical Architecture

Revised architecture · Jac-native full-stack · LLM-first culinary intelligence · Object-spatial programming · MobileNet · Stable Diffusion XL

## Architectural vision

Cooksy is an LLM-first, Jac-native culinary discovery and cooking companion that transforms available ingredients into culturally diverse, feasible meals through agentic reasoning, object-spatial graph traversal and specialised deep-learning models.

The defining decision is that Cooksy will not depend on a manually populated global recipe database.

Instead, Jac's native `by llm()` capabilities will serve as the primary culinary knowledge and reasoning mechanism. The LLM can draw upon its learned knowledge of international cuisines, cooking techniques, ingredients and established dishes to propose relevant meals dynamically.

Jac's nodes, edges and walkers will then structure that knowledge, evaluate its usefulness, connect related culinary concepts, preserve discoveries and coordinate subsequent actions.

This architecture has five complementary elements:

- LLM-driven culinary intelligence to discover dishes, interpret requests, reason about traditions and propose appropriate adaptations.
- Jac object-spatial programming to represent culinary entities, connect knowledge and execute graph-aware agentic workflows.
- MobileNet-based computer vision to assist with recognising photographed ingredients.
- Stable Diffusion XL to generate recipe-grounded serving previews after a dish is selected.
- Jac-native full-stack delivery to provide a polished, responsive user experience without introducing an unnecessary second application framework.

The central design principle is:

The LLM supplies culinary intelligence. Jac makes that intelligence structured, traversable, actionable and reusable.

## 1. Overall system architecture

# COOKSY

Your Ingredients. The World's Kitchens.

Explore · Discover · Recipe · Cook Along

Jac-native application layer

Client UI (.cl.jac)

Server-side walkers

Session & application state

API / model adapters

LLM-first culinary intelligence

`by llm()` · Culinary knowledge · Dish discovery · Contextual reasoning · Adaptation

Jac object-spatial execution

Nodes

Knowledge & state

Edges

Relationships

Walkers

Actions & traversal

Dynamic culinary graph · Structured memory · Feasibility evaluation · Workflow orchestration

MobileNet

Python · PyTorch

Ingredient-image suggestions

Stable Diffusion XL

Python · Diffusers / GPU API

Recipe-grounded visuals

Supporting data and persistence

Graph state · Validated culinary discoveries · Image cache · Food-composition references · Provenance

The LLM is intentionally central rather than an occasional fallback. However, the application should not treat every LLM response as authoritative. Jac must enforce structure, consistency, feasibility and appropriate uncertainty labels.

### Core execution principle

The system should distinguish three types of operations.

| Operation                         | Primary mechanism            | Example                                                       |
| --------------------------------- | ---------------------------- | ------------------------------------------------------------- |
| Semantic reasoning                | `by llm()`                   | Identify plausible Korean dishes using potatoes               |
| Graph reasoning and orchestration | Jac walkers, nodes and edges | Visit traditions, connect candidates and inspect requirements |
| Deterministic computation         | Jac application logic        | Calculate missing ingredients, portions and nutrition         |

This separation is important because agentic intelligence is not equivalent to asking an LLM to do everything.

## 2. Responsibilities of each technology

| Technology               | Primary responsibility                                                            | Architectural justification                                                     |
| ------------------------ | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| Jac client components    | Interface, navigation, ingredient capture, recommendations and cooking views      | Jac-native full-stack delivery                                                  |
| Jac nodes                | Represent users, pantries, ingredients, recipes, traditions and sessions          | Structured object-spatial state                                                 |
| Jac edges                | Encode culinary and workflow relationships                                        | Graph traversal and relationship-aware reasoning                                |
| Jac walkers              | Execute discovery, matching, enrichment, recipe preparation and cooking workflows | Native agentic behaviour                                                        |
| `by llm()`               | Culinary discovery, interpretation, recipe proposals and contextual assistance    | Broad learned culinary knowledge without a manually maintained recipe catalogue |
| Python + MobileNet       | Ingredient-image classification                                                   | Specialised pretrained computer vision                                          |
| Python + SDXL            | Generated serving previews                                                        | Specialised generative image modelling                                          |
| Nutrition reference data | Ingredient nutrient values                                                        | Data-grounded calculations                                                      |
| Graph persistence        | Retain discovered culinary knowledge and cooking state                            | Reuse, continuity and reduced redundant inference                               |

Python should remain a specialised inference dependency rather than a parallel application backend. This helps preserve Jac as the dominant first-party implementation language.

## 3. LLM-first culinary knowledge architecture

### 3.1 Why Cooksy does not need a manually maintained recipe catalogue

A conventional recipe application usually starts with a collection of predefined dishes. Its discovery capability is limited by which recipes developers have entered or imported.

Cooksy takes a different approach.

When a user requests meals from East Africa, South Asia, East Asia or another culinary region, the LLM can propose dishes using knowledge acquired during pretraining. The application can therefore explore a wide culinary space without first storing thousands of recipes.

For example:

> I have potatoes, eggs, spinach and onions. Show me what I can cook from East Asia.

The LLM can reason about Korean, Japanese, Chinese and other regional cooking traditions, then propose candidate dishes that are plausible for the pantry.

The graph does not need to contain those recipes beforehand.

### 3.2 What the LLM actually knows

A pretrained LLM may know many established dishes, ingredient combinations, preparation methods and regional associations. However, it does not provide a complete or independently verified culinary encyclopaedia.

It can:

- Recall widely documented dishes and techniques.
- Suggest ingredient substitutions and variations.
- Interpret natural-language cooking requests.
- Distinguish some traditional preparations from adaptations.
- Generate structured candidate recipes.

It can also misidentify a dish's origin, invent plausible-sounding names, omit essential ingredients or produce unreliable quantities.

Consequently, LLM-generated culinary knowledge is initially a proposal, not automatically a verified fact.

Cooksy should validate schemas and ingredient consistency, preserve provenance and label uncertain cultural claims appropriately. External verification may be needed for claims of authenticity.

### 3.3 Dynamic culinary discovery

User pantry + culinary intent

Ingredients · Region · Preferences · Constraints

`DiscoveryWalker` invokes `by llm()`

Reason across culinary traditions and propose dishes

Structured candidate recipes

Dish names · Traditions · Ingredients · Missing items · Preparation estimates

Jac validation and graph integration

Schema checks · Deduplication · Relationship creation · Provenance

`MatchingWalker` evaluates feasibility

Pantry coverage · Essential missing ingredients · Diversity · Practicality

Five recommended meals

User selects one before full recipe generation

### 3.4 Dynamic knowledge versus graph memory

The distinction is not that the LLM replaces the graph. It replaces the need for a large, manually curated recipe catalogue.

The graph serves as Cooksy's structured, evolving culinary memory.

As Cooksy discovers dishes, it can retain:

- Canonical dish names and possible aliases.
- Culinary regions and traditions.
- Ingredient relationships.
- Traditional and adapted variants.
- Previously assembled recipes.
- Generated image references.
- Provenance and verification status.

A previously discovered dish can be retrieved and reused, while the LLM remains available to propose alternatives, reason about new ingredients and diversify recommendations.

This creates a hybrid approach in which LLM reasoning drives discovery and graph memory improves continuity and efficiency.

## 4. Jac object-spatial culinary graph

Jac's object-spatial programming paradigm is central to Cooksy.

The nodes represent meaningful entities. Edges express relationships. Walkers move through connected entities and perform operations, including LLM-assisted reasoning.

### 4.1 Core nodes

| Node                | Represents                              | Example                      |
| ------------------- | --------------------------------------- | ---------------------------- |
| `User`              | User or guest session                   | Guest user                   |
| `Pantry`            | Confirmed available ingredients         | Current kitchen              |
| `Ingredient`        | Canonical food ingredient               | Potato                       |
| `Region`            | Broad culinary geography                | East Asia                    |
| `CulinaryTradition` | Specific culinary tradition             | Korean                       |
| `RecipeCandidate`   | Proposed dish awaiting evaluation       | Gamja-jeon proposal          |
| `Recipe`            | Accepted structured dish representation | Gamja-jeon                   |
| `RecipeVariant`     | Adapted version of a dish               | Spinach-and-potato variation |
| `RecipeStep`        | Instruction in the selected recipe      | Grate potatoes               |
| `IngredientImage`   | Uploaded image metadata                 | Pantry photo                 |
| `DetectionResult`   | Computer-vision output                  | Potato prediction            |
| `NutritionProfile`  | Estimated nutrients                     | Per-serving values           |
| `GeneratedImage`    | SDXL result and metadata                | Serving preview              |
| `CookingSession`    | Active guided-cooking state             | Step 3 of 7                  |

Adding `RecipeCandidate` makes an important distinction between an LLM proposal and a recipe accepted into the application's structured knowledge.

### 4.2 Core edges

| Edge             | Relationship                        | Function                        |
| ---------------- | ----------------------------------- | ------------------------------- |
| `HAS_INGREDIENT` | Pantry → Ingredient                 | Pantry membership               |
| `PROPOSES`       | Discovery/session → RecipeCandidate | Tracks generated suggestions    |
| `RESOLVES_TO`    | RecipeCandidate → Recipe            | Links accepted candidates       |
| `REQUIRES`       | Recipe → Ingredient                 | Quantity, unit and essentiality |
| `BELONGS_TO`     | Recipe → CulinaryTradition          | Culinary classification         |
| `PART_OF`        | CulinaryTradition → Region          | Geographic navigation           |
| `VARIANT_OF`     | RecipeVariant → Recipe              | Adaptation relationship         |
| `HAS_STEP`       | Recipe → RecipeStep                 | Cooking sequence                |
| `HAS_IMAGE`      | Recipe → GeneratedImage             | Image caching                   |
| `HAS_NUTRITION`  | Recipe → NutritionProfile           | Nutrition retrieval             |
| `DETECTS`        | IngredientImage → DetectionResult   | Vision prediction               |
| `CONFIRMED_AS`   | DetectionResult → Ingredient        | Human-confirmed identity        |
| `CURRENT_STEP`   | CookingSession → RecipeStep         | Guided cooking progress         |

These are proposed graph relationships. Their precise declarations and persistence behaviour must be verified against the Jac version used for implementation.

### 4.3 Example dynamically constructed culinary graph

East Asia

Region node

Korean

CulinaryTradition · PART_OF East Asia

LLM proposes Gamja-jeon

RecipeCandidate · Provenance: LLM-generated

Gamja-jeon

Structured Recipe node

Potato

Essential

Oil

Cooking

Salt

Seasoning

Illustrative graph. Recipe quantities and essentiality depend on the selected preparation.

The graph is constructed through application activity rather than manually populated with an exhaustive list of recipes.

The resulting relationships have operational value. A walker can traverse from a region to traditions, from traditions to dishes and from dishes to ingredient requirements, while the LLM can propose new knowledge when appropriate.

## 5. Agentic walkers and their responsibilities

The eight-walker architecture remains useful, but the responsibilities of `DiscoveryWalker` and `EnrichmentWalker` need to change.

Previously, enrichment was largely a fallback for insufficient graph coverage. In the revised architecture, LLM reasoning is a first-class part of discovery, while enrichment manages the structured knowledge produced by that reasoning.

1\. `IntakeWalker` — Ingredient understanding

Receives typed ingredients or user-confirmed MobileNet predictions. It normalises ingredient names, resolves aliases, handles duplicates and creates pantry relationships. Ambiguous ingredient descriptions can be interpreted using `by llm()`.

2\. `DiscoveryWalker` — LLM-first culinary discovery

Coordinates the central discovery process. It receives pantry information and culinary intent, retrieves relevant graph memory, invokes `by llm()` to reason about possible dishes, and returns structured candidate recommendations. Existing graph knowledge informs discovery but does not restrict it.

3\. `EnrichmentWalker` — Dynamic graph construction

Processes LLM-proposed dishes, validates their structure, checks for duplicates, creates recipe and tradition relationships, and records provenance. It can request clarification or correction through another LLM call when structured output is incomplete.

4\. `MatchingWalker` — Ingredient feasibility and ranking

Evaluates candidate dishes against the confirmed pantry. It distinguishes available ingredients, missing essentials and optional ingredients. It also considers cooking time, variety and dietary constraints. Deterministic rules should handle measurable matching wherever possible.

5\. `RecipeWalker` — Selected recipe preparation

Activates after the user selects a meal. It retrieves or requests a complete structured recipe, including ingredient quantities, portions, preparation steps and substitutions. `by llm()` may expand the selected candidate into cooking instructions, subject to consistency checks.

6\. `NutritionWalker` — Nutrition calculation

Maps quantities to food-composition reference values and calculates estimated nutrients. The LLM may assist with ingredient-name mapping but should not invent nutrient values.

7\. `VisualisationWalker` — Recipe visualisation

Constructs a recipe-grounded image prompt, invokes the SDXL inference adapter and caches the generated serving preview. Generation happens only after a dish is selected.

8\. `CookingWalker` — Interactive cooking assistance

Maintains cooking-session state, advances through recipe steps, manages timer requests and invokes `by llm()` for contextual cooking questions. The walker provides the LLM with the current step and recipe context.

### How the walkers cooperate

A user action should initiate a coherent chain of walkers rather than one large LLM prompt.

IntakeWalker

DiscoveryWalker + by llm()

EnrichmentWalker

MatchingWalker

Five meal recommendations

User selects a dish

RecipeWalker + by llm()

NutritionWalker + VisualisationWalker

CookingWalker

This flow is logical rather than a claim that all stages must run sequentially. Some operations, such as nutrition lookup and image generation, can run independently after the recipe is available.

## 6. MobileNet integration — Input-side computer vision

MobileNet provides visual ingredient suggestions for users who prefer taking photographs rather than typing ingredients.

### Processing workflow

Capture or upload photo

Python vision adapter

Decode · Resize · Normalise · MobileNet inference

Ingredient suggestions

Predicted label · Confidence · Model version

User reviews and corrects suggestions

`IntakeWalker` updates Pantry graph

### Python adapter responsibilities

The Python module should handle model loading, image preprocessing, inference and output formatting. Jac should handle request orchestration, prediction confirmation and graph updates.

Illustrative response:

```
{
  "model": "mobilenet_v3",
  "predictions": [
    {
      "ingredient": "potato",
      "confidence": 0.87
    }
  ],
  "requires_user_confirmation": true
}
```

The example confidence is hypothetical, not a tested result.

### Model limitation and practical strategy

A standard ImageNet-pretrained MobileNet is primarily an image classifier. It is not automatically a reliable detector of multiple separate ingredients within one photograph.

| Approach                                    | Capability                                                         | Implementation priority |
| ------------------------------------------- | ------------------------------------------------------------------ | ----------------------- |
| Pretrained MobileNet                        | Best-effort classification of a prominent object                   | Hackathon baseline      |
| Food-specific MobileNet checkpoint          | Better ingredient classification if suitable trained weights exist | Conditional enhancement |
| Multi-object detector or segmentation model | Locates and identifies several ingredients                         | Future improvement      |

For the initial build, the interface should make recognition editable and should not claim that the model detected every ingredient.

The typed ingredient pathway must remain fully functional if the vision model is unavailable.

## 7. Stable Diffusion XL — Output-side visual generation

SDXL generates an image of the selected meal using the structured recipe.

It is not responsible for deciding which meal to recommend or what ingredients the dish requires.

### Generation workflow

User selects a recommended meal

`RecipeWalker` assembles the recipe

Ingredients · Preparation · Tradition · Serving details

`VisualisationWalker` prepares prompt

Recipe-grounded visual description

SDXL inference

Python Diffusers or hosted GPU

AI-generated serving preview

Cached and linked to Recipe node

### Recipe-grounded prompts

A generated image should reflect the actual selected preparation.

For a Korean potato pancake, the prompt might specify a golden pan-fried grated-potato pancake with crisp edges, realistic texture and appropriate plating.

The generated image should not introduce prominent ingredients absent from the recipe.

Nevertheless, SDXL does not guarantee culinary accuracy. Cooksy should identify the output as an AI-generated serving preview.

### Deployment options

| Option                 | Advantage                      | Constraint                            |
| ---------------------- | ------------------------------ | ------------------------------------- |
| Local Python Diffusers | Greater control                | GPU requirements                      |
| Hosted SDXL inference  | Simplifies application hosting | Cost, latency and availability        |
| Cached images          | Fast repeated access           | Requires storage and cache management |

For the hackathon, hosted inference with caching is preferable if a suitable service and budget are available.

Fine-tuning SDXL using LoRA can remain a future enhancement.

## 8. LLM-driven recipe discovery and structured generation

This is the most important revised section.

### 8.1 Two-stage generation

Cooksy should separate meal discovery from full recipe preparation.

Stage A — Culinary discovery

The LLM proposes approximately five suitable meals using the pantry, region and user preferences.

At this stage, Cooksy needs only enough structured information to evaluate and display each meal:

- Dish name and culinary tradition.
- Brief description.
- Main ingredients.
- Missing essential ingredients.
- Approximate cooking time.
- Traditional dish or adaptation classification.
- Confidence or verification status where appropriate.

Stage B — Selected recipe generation

After the user selects a dish, `RecipeWalker` uses `by llm()` to assemble or retrieve the complete recipe:

- Exact ingredient quantities.
- Serving count.
- Preparation and cooking instructions.
- Cooking times and temperatures where relevant.
- Appropriate substitutions.
- Context for Cook Along.
- Inputs needed for nutrition and SDXL generation.

This approach avoids spending inference time and resources generating five full recipes when the user will choose only one.

### 8.2 Illustrative discovery request

```
{
  "pantry": [
    "potato",
    "egg",
    "spinach",
    "onion"
  ],
  "mode": "explore",
  "region": "East Asia",
  "requested_candidates": 5,
  "priorities": [
    "ingredient_feasibility",
    "culinary_diversity",
    "cultural_accuracy"
  ]
}
```

This is an illustrative application data contract, not Jac syntax.

### 8.3 Illustrative LLM response

```
{
  "dish_name": "Gamja-jeon",
  "tradition": "Korean",
  "region": "East Asia",
  "classification": "traditional_dish",
  "candidate_status": "llm_proposed",
  "ingredients": [
    {
      "name": "potato",
      "quantity": 300,
      "unit": "g",
      "essential": true
    },
    {
      "name": "cooking oil",
      "quantity": 15,
      "unit": "ml",
      "essential": true
    }
  ],
  "estimated_minutes": 25
}
```

The data is illustrative and incomplete. It should not be treated as a verified recipe.

### 8.4 Validation and safeguards

Before presenting candidates, Cooksy should check whether the response has a valid structure, whether ingredient requirements are coherent, whether suggested substitutions are reasonable and whether any stated dietary constraints are satisfied.

The system should also distinguish:

| Classification        | Meaning                                                        |
| --------------------- | -------------------------------------------------------------- |
| Traditional dish      | A recognised dish associated with a culinary tradition         |
| Traditional variation | A plausible variation within established preparation practices |
| Cooksy adaptation     | A creative modification using available ingredients            |
| Fusion dish           | A deliberate combination of culinary influences                |

An LLM may propose a classification, but the classification alone does not establish authenticity. Where evidence is unavailable, Cooksy should avoid definitive historical or cultural claims.

### 8.5 Dynamic graph reuse

The `EnrichmentWalker` should compare newly proposed dishes against existing graph knowledge.

If an equivalent dish already exists, it should reuse or update the appropriate structured representation rather than creating unnecessary duplicates.

If a genuinely new candidate is proposed, it can create a new candidate node and related ingredient or tradition edges.

The LLM can still contribute new recommendations on subsequent requests. Graph memory improves efficiency without becoming a restrictive catalogue.

## 9. Five-meal recommendation experience

The user should receive approximately five choices before full recipe generation.

COOKSY · EXPLORE

# Discover East Asia

Your pantry · Potatoes, eggs, spinach, onions

[A guide to different (and delicious) pancakes in Asia | Tatler Asia](https://images.openai.com/static-rsc-4/G3aoWAi09Ldvv2rvMQvQl8loKAbz84ObKrI2ZItBMGeAGv29Oq5wWtVYJlXDPX3jUgDAm2vb7fsdh9NhTU7NPqbyylj7y0-AR9ZgTdqhJHQDVnN1VMaKhOjL3JKUMW0A6ALv0QtCnuEsfjM9SsS6vOKzkfEr6bHf6Y3OPHMR5S0?purpose=inline)

Gamja-jeon

Korean · \~25 min

Almost ready

Check oil and salt

[Japanese rolled omelette. Tavern cuisine.](https://images.openai.com/static-rsc-4/VdU9bXrCWD6LC_NLQ0zSeMhtlghpWwoqctN6hkKZmOlQvVuzreeL0YeFM7Yxdml2nV9EOkn8nPZ33AZyLb38XFk19n0SZgkzx9-srryoLQuBv84QKuAstk9VzqjDdg4cEFkdpH185fJ9tmSWNlfNVxOjj4JWNSeE-IxiY4jKpWi0bAt9lmyusHqZcYdXfD9_?purpose=inline)

Tamagoyaki

Japanese · \~15 min

Almost ready

Seasonings vary by recipe

[图文详情页](https://images.openai.com/static-rsc-4/IBKL_v9kmzSLgllYNQ70HDVmj2cwhJe6dC5_g5W8puk1pEBkgbV3EW_pmm69IBY8K3OYDCCjMaheyXIv8ALUTFJPOE73g3S6PlRFAOCtzyiXb68QxwhE-a7o2vcuERXvZkXIgEOT1RABoJSNt27V5vdqcpMB2JkbB9vG94xkYDc?purpose=inline)

Stir-fried greens

Chinese-style · \~10 min

Almost ready

Cooking oil needed

[Korean Rolled Omelette (Gyeran Mari)](https://images.openai.com/static-rsc-4/i3yhBiu-G46r0JzY4N45v0AwMIwEvFDcJNbSH58JEHd56fZcWIBwGWOL41V9J5tN54TYISgoWbKcK5Hc6d5pqy7MeQT_UASd1mWyTvnODZIa3X3EKp5szJ9TpjTpU9N3HI72FpHdZcSF8_HF0M8QmJWi9ijPGO1NVgPhFFVqaTE?purpose=inline)

Gyeran-mari

Korean · \~15 min

Almost ready

Check oil and seasoning

[Korokke Recipe (Fried, with Meat and Vegetables) | The Kitchn](https://images.openai.com/static-rsc-4/YXwitaKb_ksdeE3KlDObNpB9VXUPSDeChLqBH3_2HY_li545ikv119K3psfViE9k6z8uIUH2-ic6CtGs2iowW-8oOd6g0H4AryFsCZNHLMa_tZxd78Sf2TBoaW96t9T5a6IGpSuDPYnV9gW8pCrhWNHG3EmlewnHXhtNTcEy0CM?purpose=inline)

Korokke

Japanese · \~45 min

Needs shopping

Breadcrumbs, flour and frying oil

Illustrative interface, not actual Cooksy model output. Missing ingredients depend on the selected recipe and confirmed pantry staples.

The recommendations should be ranked by actual pantry feasibility, not simply by how confidently the LLM describes a dish.

A useful ranking strategy is to combine ingredient coverage, essential missing ingredients, preparation time, dietary suitability and culinary diversity.

The LLM proposes candidates. Jac evaluates and orders them.

## 10. Nutrition engine

Nutrition is an important area where deterministic computation should take precedence over free-form LLM generation.

The LLM can help interpret ingredient descriptions and map recipe terms to food-composition categories. However, nutrient values should come from an appropriate reference dataset, such as USDA FoodData Central or a suitable regional food-composition source.

For nutrient \\(k\\):

\\[ N\_{k,\mathrm{recipe}}=\sum\_{i=1}^{n}\frac{q_i}{100}N\_{ik} \\]

Where \\(q_i\\) is the edible quantity of ingredient \\(i\\) in grams and \\(N\_{ik}\\) is the amount of nutrient \\(k\\) per 100 grams of that ingredient.

For \\(s\\) servings:

\\[ N\_{k,\mathrm{serving}}=\frac{N\_{k,\mathrm{recipe}}}{s} \\]

This baseline calculation does not automatically account for cooking losses, absorbed oil, moisture changes or yield adjustments.

The `NutritionWalker` should therefore communicate that nutrition values are estimates and should omit values that cannot be supported by available data.

Unlike the recipe catalogue, food-composition data is a legitimate reason to use an external structured dataset, because nutritional quantities require reference measurements rather than culinary recollection.

## 11. Proposed unified application structure

```
cooksy/
│
├── jac.toml
├── app.jac
│
├── frontend/
│   ├── App.cl.jac
│   ├── Home.cl.jac
│   ├── Explore.cl.jac
│   ├── Discover.cl.jac
│   ├── IngredientCapture.cl.jac
│   ├── MealResults.cl.jac
│   ├── RecipeDetail.cl.jac
│   ├── CookAlong.cl.jac
│   ├── components/
│   │   ├── IngredientChip.cl.jac
│   │   ├── RegionCard.cl.jac
│   │   ├── MealCard.cl.jac
│   │   └── StepCard.cl.jac
│   └── styles.css
│
├── graph/
│   ├── nodes.jac
│   ├── edges.jac
│   └── persistence.jac
│
├── walkers/
│   ├── intake.jac
│   ├── discovery.jac
│   ├── enrichment.jac
│   ├── matching.jac
│   ├── recipe.jac
│   ├── nutrition.jac
│   ├── visualisation.jac
│   └── cooking.jac
│
├── intelligence/
│   ├── culinary_reasoning.jac
│   ├── prompts.jac
│   ├── schemas.jac
│   ├── validation.jac
│   └── provenance.jac
│
├── adapters/
│   ├── vision_adapter.py
│   └── sdxl_adapter.py
│
├── data/
│   ├── regions.json
│   └── ingredient_aliases.json
│
└── README.md
```

The major addition is `culinary_reasoning.jac`, representing the central LLM-assisted culinary reasoning capability.

This repository layout is a design proposal, not verified compile-ready Jac syntax. The actual structure should follow the conventions supported by the installed Jac version, including its client components, Python interoperability and deployment system.

### Code distribution

| Language | Intended role                                                                  |
| -------- | ------------------------------------------------------------------------------ |
| Jac      | Main application, frontend, walkers, graph, LLM integration and business logic |
| Python   | Minimal MobileNet and SDXL adapters                                            |
| CSS      | Visual design and responsive styling                                           |
| JSON     | Configuration and small reference mappings                                     |

The hackathon's 80% Jac requirement makes it especially important to keep the primary implementation Jac-native. The organisers' exact counting method should be confirmed rather than assumed.

## 12. Deployment architecture

The recommended deployment separates the Jac application from heavyweight model inference when necessary.

Browser

Cooksy client interface

Jac application host

Frontend · Graph · Walkers · `by llm()`

Vision service

MobileNet inference

CPU / GPU

Image service

SDXL inference

Hosted GPU

Persistent resources

Graph state · Recipe cache · Generated images · Reference data

Jac Hammer is a potential hosting option, subject to verifying support for the application's required runtime, graph persistence and model integrations.

Important operational requirements include server-side API credentials, image validation, model timeouts, inference-cost controls, privacy-aware photo handling and graceful degradation when external services fail.

A failure in SDXL should not prevent the user from viewing or cooking the selected recipe.

## 13. Hackathon implementation priorities

The implementation must remain focused because the official agenda sets a Saturday 3:30 PM EAT submission deadline.

The Hacker Guide also requires a working demonstration, GitHub repository, pitch deck, written explanation and substantial use of Jac.

Tier 1 — Essential working application

Jac-native interface, typed ingredient entry, Explore and Discover, `by llm()` culinary discovery, meaningful nodes and edges, working walkers, five candidate meals, feasibility evaluation and full selected-recipe generation.

Tier 2 — Differentiating AI capabilities

MobileNet-assisted photo intake, editable recognition results, SDXL recipe previews, Cook Along, graph persistence and a developer-facing agent trace.

Tier 3 — Future enhancements

Improved multi-ingredient detection, food-specific vision checkpoints, SDXL LoRA, broader nutrition coverage, stronger cultural provenance verification and personalised culinary recommendations.

The central hackathon priority is to demonstrate that the LLM and the Jac object-spatial system genuinely cooperate.

It is better to have five dynamically discovered, correctly evaluated meals than a visually elaborate interface whose backend is only a single LLM call.

## 14. Demonstrating agentic intelligence to the judges

Cooksy's strongest demonstration should make its reasoning and graph operations visible.

The consumer experience remains simple, but an optional developer panel can show what happens behind the scenes.

Cooksy Agent Trace

Illustrative

1. IntakeWalker — Normalised four confirmed pantry ingredients
2. DiscoveryWalker — Invoked LLM culinary reasoning for East Asia
3. EnrichmentWalker — Created or reused structured candidate relationships
4. MatchingWalker — Evaluated missing ingredients and ranked candidates
5. RecipeWalker — Prepared the user-selected recipe
6. VisualisationWalker — Requested a recipe-grounded serving preview
7. CookingWalker — Started an interactive cooking session

Proposed developer view. Actual traces should be generated from recorded walker events, not hardcoded demo messages.

This would demonstrate the difference between Cooksy and a generic recipe chatbot.

A generic chatbot receives a prompt and produces text.

Cooksy receives a request, activates walkers, reasons through an LLM, constructs and traverses culinary relationships, evaluates feasible options, maintains state and supports the user through cooking.

That is the agentic behaviour the implementation should substantiate.

## 15. Final architectural decision

Cooksy's revised technical identity

LLM

Discovers and reasons about culinary knowledge

Jac

Structures, traverses and operationalises knowledge

MobileNet

Assists with understanding ingredient photographs

SDXL

Visualises the chosen meal

The full product flow becomes:

Ingredient capture → Jac pantry graph → LLM-driven culinary discovery → Dynamic graph construction and traversal → Feasibility evaluation → Five meal choices → Selected recipe generation → Nutrition and SDXL visualisation → Interactive Cook Along.

This design eliminates the need for a manually maintained global recipe database while retaining the benefits of structured memory and deterministic application logic.

It also establishes a meaningful reason for every major technology in the stack.

Cooksy is not a recipe database with an AI search feature. It is an agentic culinary discovery system that uses LLM knowledge to explore the world's kitchens, Jac's object-spatial programming to organise and act on that knowledge, and deep-learning models to connect the user's real ingredients with an engaging cooking experience.