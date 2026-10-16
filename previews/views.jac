obj PreviewView {
    has status: str,
        image: str,
        model: str,
        provider: str,
        message: str,
        prompt: str,
        cache_key: str,
        created_at: str,
        seed: int;

    has cached: bool = False;
    has label: str = "AI-generated serving preview; illustrative, not an exact photograph.";
}
