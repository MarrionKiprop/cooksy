# M6 verification

Local environment: /home/langstkip/workspace/langstEnv/bin/python, CPU torch
2.13.0+cpu, torchvision 0.28.0+cpu. Official MobileNetV3 Small ImageNet V1 weights:
https://download.pytorch.org/models/mobilenet_v3_small-047dcff4.pth
SHA256 047dcff4addef86ea5bc2eff13c9614dc11f47ab1160d0a71a25e7db994f4e1f.
Weights are ignored under models/, never committed. No provider or cloud photo API.
Model reference: https://docs.pytorch.org/vision/main/models/generated/torchvision.models.mobilenet_v3_small.html
Standard ImageNet whole-image classifier, not multi-object ingredient detection.
Only conservative ingredient labels among top five predictions with score >=0.05
are proposed. Scores are model probabilities, not calibrated correctness guarantees.

Adapter tests: six PASS (media/size/pixel bounds, actual JPEG/PNG decoding, demo
contract/disclosure, unavailable weights, conservative label mapping). Real CPU
inference on a synthetic color image: PASS, honest no_match (not an accuracy test).
Four Jac vision tests PASS: explicit confirmation/edits/rejection/merge, tampered
and expired signed receipts, invalid input, timeout sanitization and actual graph
links independent of traversal order. No claim of measured real-food accuracy.
Initial checks caught constructor/tuple syntax and a reused test variable type;
corrected in source. Browser FileReader uses localized JS any boundary. No framework
or generated source modifications. Full regression: 40 Jac tests PASS (47.51s), full check 59 files PASS (133.02s),
client build PASS. All eight browser suites PASS, including vision-smoke with real
photo decode/local inference/demo/confirmation and mocked culinary LLM. Desktop/mobile
photo-review captures reviewed. Wrong-weight checksum rejection also tested.
