"""Explicit name aliases; no heuristic stemming, quantities, or assumed staples."""
glob ALIASES: dict[str, str] = {
         "potatoes": "potato",
         "eggs": "egg",
         "onions": "onion",
         "tomatoes": "tomato",
         "red lentils": "red lentil",
         "cooked chickpeas": "cooked chickpea",
         "chickpeas": "chickpea",
         "green peppers": "green pepper",
         "oil": "cooking oil",
         "vegetable oil": "cooking oil",
         "scallions": "spring onion",
         "scallion": "spring onion"
     };

def normalise_name(raw: str) -> str {
    name = " ".join(raw.strip().lower().split());
    if not name or len(name) > 64 {
        return "";
    }
    has_letter: bool = False;
    for char in name {
        if char.isalpha() {
            has_letter = True;
        }
        if not char.isalpha() and char not in " -'" {
            return "";
        }
    }
    return ALIASES.get(name, name) if has_letter else "";
}

def split_names(raw: str) -> list[str] {
    return raw.replace("\n", ",").replace(";", ",").split(",");
}
