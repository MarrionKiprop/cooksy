# Follow-ups after M8

The user deliberately deferred these so the core milestones could be finished.
They remain visible work, not completed production capabilities.

1. **Activate real SDXL serving previews.** First obtain a hosted SDXL service or
   suitable GPU/model runtime. Existing selected-recipe adapter, prompt, graph cache
   and UI can be reused. Verify the provider-specific contract and one explicitly
   authorized generation; retain illustrative labels and error/cost controls.
   Current demo is an abstract plate, not a generated meal photograph.
2. **Food-specific vision and multiple ingredients.** Current MobileNet ImageNet
   classification missed the user's mixed fish/green-banana/chilli photo and gave
   low-confidence unrelated labels. Compare suitable food checkpoints/detection
   models, dataset coverage/licensing and measured accuracy; improve abstention
   before treating low scores as useful suggestions. Preserve mandatory review.
3. **Durable culinary graph memory.** Current public recipe/preview caches expire
   on restart. Design durable storage, migrations, retention and private/account
   ownership before moving graph content into persistent roots. User pantry and
   cooking progress remain tab-local; no account sync is implied.
4. **Broader nutrition coverage.** Add traceable regional references, cooked states,
   food-specific portion masses and supported density/yield data. Keep unknowns
   explicit and avoid conflating pantry names with measured edible quantities.
5. **Production readiness.** Deployment/authentication, spending/rate limits,
   operational monitoring, provider-specific live checks, independent food review
   and broader human accessibility/device testing remain separate work.

Pick up a follow-up only when the user chooses it; do not silently download model
weights, spend provider credits, or change the application's privacy boundaries.

## Hosted demonstration decision — 17 October 2026

Defer real photo recognition and SDXL in JacHammer; demonstrate typed ingredient
intake and the culinary workflow instead. No further model installations, weight
downloads or paid inference are authorized by this decision.

- **Photo recognition:** the attempted CPU PyTorch installation exited137 and the
  sandbox pod subsequently became unavailable. OOM/eviction was not established.
  Hosted inference setup and validation remain incomplete. Revisit with an adequate
  prebuilt runtime, persistent/reproducible provisioning or a separately approved
  hosted vision integration. Existing local classification accuracy limits remain.
- **SDXL:** no confirmed CUDA runtime, model installation or hosted provider.
  Existing adapter/UI are implemented; real generation remains unverified. Revisit
  provider/runtime selection and an explicitly approved live check later.

The reported sandbox uses emptyDir volumes: data may survive container restarts
within the same pod, but is lost when that pod is removed. Persistent deployment
support has not been established. Sample modes remain explicitly labelled.

## ZeroGPU integration preparation

The user created LangstKip/cooksy-sdxl to pursue a recorded SDXL demo. Upload files
and a compatible Cooksy queued-API adapter are now prepared in
`deploy/huggingface-sdxl/`; see DEVELOPMENT.md. This reopens SDXL integration
preparation only. Deployment, GPU execution and quota handling remain unverified.
The photo-recognition deferral and production-hosting limitations remain.
