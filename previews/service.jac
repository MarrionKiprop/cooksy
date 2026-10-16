"""Selected graph recipe → deterministic prompt → bounded optional SDXL adapter."""
import os;
import shutil;
import json;
import subprocess;
import from pathlib { Path }
import from hashlib { sha256 }
import from datetime { datetime, timezone }
import from threading { RLock }
import from graph.models { Recipe, HAS_STEP, REQUIRES }
import from graph.projections { recipe_view }
import from graph.views { RequirementView }
import from ai.memory { request_catalogue }
import from walkers.recipe { RecipeWalker }
import from .models {
    PreviewCache,
    GeneratedImage,
    CACHED_IMAGE,
    HAS_PREVIEW,
    GENERATED_FOR
}
import from .views { PreviewView }

glob cache: PreviewCache = PreviewCache(),
     lock = RLock();
glob negative_prompt: str = "text, watermark, raw unfinished meal, unrelated side dishes, extra garnish not in recipe";

def prompt_for(recipe: Recipe) -> str {
    view = recipe_view(recipe);
    view.requirements.sort(
        key=lambda (item: RequirementView) -> str { return item.name; }
    );
    ingredients = "; ".join(
        [
            str(i.quantity)
                + " "
                + i.unit
                + " "
                + i.name
                + (" (" + i.preparation + ")" if i.preparation else "")
            for i in view.requirements
        ]
    );
    method = " ".join([step.instruction for step in view.steps]);
    prompt = "Illustrative food photography of the finished dish: "
        + view.name
        + ". "
        + view.description
        + ". Culinary context: "
        + view.tradition
        + ", "
        + view.region
        + ". Recipe for "
        + str(view.servings)
        + " servings. Declared ingredients: "
        + ingredients
        + ". Preparation: "
        + method
        + ". Show one finished serving on a simple plate, natural light. Use only the declared ingredients; no invented garnish, labels or text. Appearance is illustrative, not proof of exact quantities or authenticity.";
    if len(prompt) > 10000 {
        raise ValueError("Recipe is too long for a serving preview.");
    }
    return prompt;
}

def provider_mode(demo: bool) -> str {
    mode = os.environ.get("COOKSY_SDXL_MODE", "off");
    return "demo" if demo else (mode if mode in ["local", "hosted"] else "off");
}

def key_for(recipe: Recipe, prompt: str, mode: str) -> str {
    return sha256(
        (
            "cooksy-preview-v1|"
            + recipe.key
            + "|"
            + recipe.version
            + "|"
            + prompt
            + "|"
            + negative_prompt
            + "|"
            + mode
            + "|"
            + os.environ.get(
                "COOKSY_SDXL_MODEL_ID", "stabilityai/stable-diffusion-xl-base-1.0"
            )
            + "|"
            + os.environ.get("COOKSY_SDXL_ENDPOINT", "")
            + "|"
            + os.environ.get("COOKSY_SDXL_MODEL_PATH", "")
            + "|768x768|25steps"
        ).encode()
    ).hexdigest();
}

def run_adapter(prompt: str, seed: int, mode: str) -> dict[str, any] {
    if mode == "off" {
        return {
            "status": "unavailable",
            "image": "",
            "model": "SDXL",
            "provider": "unconfigured",
            "message": "SDXL is not configured. Try the labelled demo layout; your recipe is still available."
        };
    }
    script = str(
        Path(__file__).resolve().parent.parent / "adapters" / "sdxl_adapter.py"
    );
    executable = os.environ.get("COOKSY_SDXL_PYTHON", "")
        or shutil.which("python3")
        or "";
    try {
        result = subprocess.run(
            [executable, script],
            input=json.dumps(
                {
                    "prompt": prompt,
                    "negative_prompt": negative_prompt,
                    "seed": seed,
                    "mode": mode
                }
            ),
            capture_output=True,
            text=True,
            timeout=100,
            check=True
        );
        raw = json.loads(result.stdout) as dict[str, any];
        if raw["status"] not in ["ready", "demo", "unavailable", "error"] {
            raise ValueError("Unknown preview state");
        }
        image = str(raw["image"]);
        if len(image) > 2800000
            or (
                raw["status"] == "ready"
                and not (
                    image.startswith("data:image/png;base64,")
                    or image.startswith("data:image/jpeg;base64,")
                )
            ) {
            raise ValueError("Invalid image response");
        }
        return raw;
    } except Exception {
        return {
            "status": "error",
            "image": "",
            "model": "SDXL",
            "provider": mode,
            "message": "Preview generation failed or timed out. Your recipe and progress are unchanged."
        };
    }
}

def project(image: GeneratedImage, cached: bool) -> PreviewView {
    return PreviewView(
        status=image.status,
        image=image.image,
        model=image.model,
        provider=image.provider,
        message="DEMO: layout only; no SDXL image was generated."
            if image.status == "demo"
            else "Illustrative serving preview; actual appearance may differ.",
        prompt=image.prompt,
        cache_key=image.cache_key,
        created_at=image.created_at,
        seed=image.seed,
        cached=cached
    );
}

walker VisualisationWalker {
    has store: PreviewCache,
        mode: str,
        generate: bool;

    has result: PreviewView | None = None,
        selected: Recipe | None = None,
        prompt: str = "",
        cache_key: str = "",
        events: list[str] = [];

    can recipe with Recipe entry {
        self.selected = here;
        self.prompt = prompt_for(here);
        self.cache_key = key_for(here, self.prompt, self.mode);
        self.events.append(
            "Read selected recipe requirements and ordered preparation."
        );
        # Graph traversal performs cache lookup, rather than a separate JSON catalogue.
        visit [self.store->:CACHED_IMAGE:->];
    }

    can cached_image with GeneratedImage entry {
        if here.cache_key == self.cache_key {
            self.result = project(here, True);
            self.events.append("Reused recipe/prompt/version-matched serving preview.");
        }
    }

    can finish with Recipe exit {
        if self.result is not None {
            return;
        }
        seed = int(self.cache_key[:8], 16) % 2147483648;
        if not self.generate {
            self.result = PreviewView(
                status="not_requested",
                image="",
                model="SDXL",
                provider=self.mode,
                message="Generate an optional serving preview after selecting your recipe. Nothing is generated automatically.",
                prompt="",
                cache_key=self.cache_key,
                created_at="",
                seed=seed
            );
            return;
        }
        raw = run_adapter(self.prompt, seed, self.mode);
        status = str(raw["status"]);
        self.result = PreviewView(
            status=status,
            image=str(raw["image"]),
            model=str(raw["model"]),
            provider=str(raw["provider"]),
            message=str(raw["message"]),
            prompt=self.prompt,
            cache_key=self.cache_key,
            created_at="",
            seed=seed
        );
        if status not in ["ready", "demo"] {
            return;
        }
        image = GeneratedImage(
            cache_key=self.cache_key,
            recipe_key=here.key,
            recipe_version=here.version,
            status=status,
            image=str(raw["image"]),
            model=str(raw["model"]),
            provider=str(raw["provider"]),
            prompt=self.prompt,
            created_at=datetime.now(timezone.utc).isoformat(),
            seed=seed
        );
        here +>:HAS_PREVIEW():+> image;
        image +>:GENERATED_FOR():+> here;
        self.store +>:CACHED_IMAGE():+> image;
        images = [self.store->:CACHED_IMAGE:->];
        if len(images) > 16 {
            oldest = sorted(
                images,
                key=lambda (item: GeneratedImage) -> str { return item.created_at; }
            )[0];
            del oldest;
        }
        self.result = project(image, False);
        self.events.append(
            "Cached generated image state and recipe-grounded metadata."
        );
    }
}

def selected_preview(
    recipe_key: str, version: str, generate: bool, demo: bool
) -> PreviewView {
    if len(recipe_key) > 100 or len(version) > 100 {
        raise ValueError("Invalid recipe identity.");
    }
    selection = request_catalogue() spawn RecipeWalker(recipe_key=recipe_key);
    recipe = selection.selected_node;
    if recipe is None {
        raise ValueError(
            "Select an available full recipe before requesting a preview."
        );
    }
    if recipe.version != version {
        raise ValueError("Recipe changed. Reload before requesting a preview.");
    }
    with lock {
        walking = recipe spawn VisualisationWalker(
            store=cache, mode=provider_mode(demo), generate=generate
        );
        if walking.result is None {
            raise ValueError("Preview did not finish.");
        }
        return walking.result;
    }
}
