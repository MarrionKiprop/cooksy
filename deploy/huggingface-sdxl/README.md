---
title: Cooksy SDXL
emoji: 🍽️
colorFrom: green
colorTo: yellow
sdk: gradio
sdk_version: 6.30.0
python_version: '3.12'
app_file: app.py
pinned: false
short_description: Illustrative recipe images with SDXL on ZeroGPU
---

# Cooksy serving previews

AI-generated serving preview; illustrative, not an exact photograph.

This Space runs SDXL Base 1.0 at 768×768 and 25 steps. Its first build downloads
model weights; GPU execution occurs only on an explicit generation request.
Choose **ZeroGPU** in Space hardware settings. No OpenAI key is needed.

The Gradio API is `/generate`, with inputs `prompt`, `negative_prompt`, `seed`.
It returns an image for the demo UI and a JSON image/metadata object for Cooksy.
Public visitors can use this API. Daily quotas, queues, startup time and Space
availability apply; it is not permanent, dedicated inference hosting.
Prompts are sent to Hugging Face. Gradio may temporarily cache generated images;
do not include private information. Long recipe prompts may be truncated by SDXL's
text encoders. Images do not prove recipe accuracy, ingredients or authenticity.

Model: https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0
Model use is governed by its CreativeML Open RAIL++-M license. No model weights
are committed in this repository. Application source has no separate license grant.
