import from graph.models { Recipe }
node PreviewCache {}
node GeneratedImage {
    has cache_key: str,
        recipe_key: str,
        recipe_version: str,
        status: str,
        image: str,
        model: str,
        provider: str,
        prompt: str,
        created_at: str,
        seed: int;
}

edge CACHED_IMAGE: PreviewCache --> GeneratedImage {}
edge HAS_PREVIEW: Recipe --> GeneratedImage {}
edge GENERATED_FOR: GeneratedImage --> Recipe {}
