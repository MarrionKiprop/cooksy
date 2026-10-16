# Cooksy

**Your Ingredients. The World’s Kitchens.**

Discover meals from what you already have. Build your pantry, explore culinary
traditions around the world, choose a dish, and cook it one step at a time.

- Add ingredients in your own words or review suggestions from a photo.
- Explore 15 culinary regions or discover dishes worldwide.
- Compare five meal ideas by ingredients on hand and what you still need.
- Open a recipe with quantities, instructions and nutrition estimates where supported.
- Follow cook-along steps and return to your saved progress.

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
set and clearly identifies incomplete subtotals.

Real serving-image generation requires a separately configured SDXL provider or
local GPU setup. The sample layout does not generate a food image. Pantry and
cooking progress are saved in the current browser tab; generated recipes and
preview memory currently expire when the server restarts.

## Documentation

- [Getting started and walkthrough](docs/DEMO.md)
- [Developer setup, providers and tests](docs/DEVELOPMENT.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Nutrition sources and methodology](docs/NUTRITION.md)
- [Planned improvements](docs/FOLLOW_UPS.md)

Built with Jac. [Source repository](https://github.com/MarrionKiprop/cooksy).
