# Remaining work

The user has verified both SDXL serving images and MobileNet photo review through
Cooksy using the [Hugging Face Space](https://huggingface.co/spaces/LangstKip/cooksy-sdxl).
The Space owns its inference application; Cooksy owns the Jac workflow and thin
provider adapters. Hosting both image models there avoids installing them in the
JacHammer sandbox, where a prior PyTorch installation exited137. Its cause was not
confirmed. JacHammer still requires the server environment settings documented in
[DEVELOPMENT.md](DEVELOPMENT.md).

1. **Food-specific vision and multiple ingredients.** MobileNet is a general
   prominent-object classifier and can misidentify food. Compare suitable food
   checkpoints/detection models, dataset coverage/licensing and measured accuracy.
   Preserve abstention, editable review and mandatory confirmation.
2. **Serving-image quality and reliable inference hosting.** Images are illustrative
   and may not match the finished dish. Improve prompt focus where useful, verify
   cache reuse/no generation on load in the recorded workflow, and account for
   shared GPU quotas, queues, startup and availability. Do not claim production SLA.
3. **Durable culinary graph memory.** Recipe/preview caches expire on restart.
   Design storage, migrations, retention and account ownership before persisting
   graph content. Pantry and cooking progress remain tab-local, without account sync.
4. **Broader nutrition coverage.** Add traceable regional references, cooked states,
   portion masses and supported density/yield data. Keep unsupported amounts explicit.
5. **Production readiness.** Deployment/authentication, spending/rate limits,
   monitoring, independent culinary review and broader accessibility/device testing.

For the recording, both image features can use Hugging Face while Cooksy runs
locally. Disclose provider processing, classifier accuracy and shared GPU limits.
Samples remain explicitly labelled and do not demonstrate real inference.
Do not download models, spend credits or change photo-sharing boundaries without
an explicit task or authorization. Configuration and checks are in DEVELOPMENT.md.
