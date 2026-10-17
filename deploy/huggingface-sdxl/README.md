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

This Space also exposes CPU MobileNet ingredient review through `/review_photo`.
Its data-URL input is validated in memory; suggestions require confirmation in
Cooksy and never change the pantry automatically. The model classifies one
prominent object, not all ingredients in a scene. It can be wrong. Official
MobileNet weights are fetched and SHA-256 checked on the first valid photo request.

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

To prepare all four upload files from the Cooksy repository, run
`python deploy/huggingface-sdxl/prepare_upload.py`. Upload the contents of
`build/huggingface-sdxl/` to the Space root, including `vision_adapter.py`.
The shared classifier source is copied from Cooksy's adapter, avoiding a divergent
label map or validation implementation. CPU photo review has its own queue and
makes no SDXL GPU reservation. Photos pass through Hugging Face; platform request
retention is outside Cooksy's control. Avoid private images.
