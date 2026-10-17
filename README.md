# Cooksy

**Your Ingredients. The World’s Kitchens.**

Discover meals from what you already have. Build your pantry, explore culinary
traditions around the world, choose a dish, and cook it one step at a time.

- Add ingredients in your own words or review suggestions from a photo.
- Explore 15 culinary regions or discover dishes worldwide.
- Compare five meal ideas by ingredients on hand and what you still need.
- Open a recipe with quantities, instructions and nutrition estimates where supported.
- Follow cook-along steps and return to your saved progress.
- Generate an illustrative serving preview of your selected dish with SDXL.

## How it works

Cooksy combines **Jac graph traversal and structured LLM reasoning**. Confirmed
ingredients feed either regional Explore or worldwide Discover. The app checks
its culinary graph memory, asks the LLM for additional candidates when needed,
then validates and ranks them against your ingredients. Discovery prioritizes
established regional dishes and local names, with adaptations identified explicitly.

You choose from five meal ideas. Only the selected dish is expanded into a full
recipe with quantities and ordered instructions. Matching, validation, nutrition
arithmetic and cooking progress stay in Jac; recipes are not limited to a fixed
food database. OpenAI is called through Jac's `by llm` functions.

### Images and photo recognition

The companion [Cooksy Hugging Face Space](https://huggingface.co/spaces/LangstKip/cooksy-sdxl)
hosts two inference services:

- **SDXL:** `stabilityai/stable-diffusion-xl-base-1.0` generates a serving image
  on shared ZeroGPU hardware. Cooksy builds the prompt from the selected recipe;
  generation runs only when requested, and successful previews are cached.
- **MobileNetV3 Small:** runs on the Space CPU and proposes ingredient labels
  from a photo. You review, correct and confirm suggestions before adding them
  to the shared pantry. It classifies prominent objects rather than detecting
  every ingredient in a mixed photograph.

Cooksy remains a Jac application running locally or in JacHammer; Hugging Face
handles these image-model calls. Model-service source lives in the Space repository,
while this repository contains the adapters and Jac application. See
[hosted-service setup](docs/DEVELOPMENT.md#hugging-face-image-services) for configuration.

## Run locally

Cooksy uses Jac 0.37.25. From the project directory:

```bash
jac install --frozen
jac run --dev
```

Open http://localhost:8000. On WSL, use `http://<WSL-IP>:8000` if Windows localhost
forwarding is unavailable. Find the address with `hostname -I`.

For AI recipe discovery, configure `OPENAI_API_KEY` in your local `.env` using
[.env.example](.env.example) as a reference. Keep credentials out of source control.
Without a provider, you can browse explicitly labelled sample recipes.

## Current availability

Recipes created with AI need a review of ingredient amounts and instructions.
Photo recognition supports a limited range of ingredients; suggestions must be
confirmed before they enter your pantry. Nutrition uses a small sourced reference
set and clearly identifies incomplete subtotals. An optional AI action estimates
missing food composition or portion masses, with assumptions and separate labels.

SDXL and photo recognition have been demonstrated through the Hugging Face service.
Other installations must configure those endpoints separately. Shared GPU queues,
quotas and service availability can delay or prevent image generation. Generated
images are illustrative and may differ from the actual dish. The sample layout
does not generate a food image. JacHammer's sandbox could not reliably host the
local model dependencies, so the demonstration uses external inference instead.

Pantry and cooking progress are saved in the current browser tab; generated recipes and
preview memory currently expire when the server restarts.

## Project structure

`jac.toml` selects `main.jac` as the entry point. Its `app()` renders the routed
page content. `pages/` defines screens and the shared layout; feature folders
contain their components and services. `endpoints.jac` exposes server operations,
and `graph/` plus `walkers/` hold the culinary graph and its traversal logic.

`.env.example` documents configuration without secrets; copy it to a local `.env`.
Generated `.jac/` files, installed dependencies, model weights and local development
records are excluded from Git. Tests and setup documentation remain in the repository.

## Documentation

- [Getting started and walkthrough](docs/DEMO.md)
- [Developer setup, providers and tests](docs/DEVELOPMENT.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Nutrition sources and methodology](docs/NUTRITION.md)
- [Planned improvements](docs/FOLLOW_UPS.md)

Built with Jac. [Source repository](https://github.com/MarrionKiprop/cooksy).
