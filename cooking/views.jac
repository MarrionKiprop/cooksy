obj CookingView {
    has recipe_key: str,
        recipe_name: str,
        current_sequence: int,
        total_steps: int,
        completed: list[int],
        finished: bool,
        instruction: str;

    has version: str = "cooksy-demo-v1";
}
