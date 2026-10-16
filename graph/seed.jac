"""Small isolated graph fixture; never attaches to root or calls a model.

Quantities and steps are unverified developer examples for topology tests.
They do not establish culinary authenticity, nutrition, or a complete recipe.
"""
import from .models {
    CulinaryCatalogue,
    Region,
    CulinaryTradition,
    Ingredient,
    Recipe,
    RecipeStep,
    CATALOGUE_TRADITION,
    CATALOGUE_RECIPE,
    IN_REGION,
    PART_OF,
    BELONGS_TO,
    REQUIRES,
    HAS_STEP
}

def add_region(
    catalogue: CulinaryCatalogue,
    key: str,
    name: str,
    subtitle: str,
    motif: str,
    tone: str
) -> Region {
    region = Region(key=key, name=name, subtitle=subtitle, motif=motif, tone=tone);
    catalogue +>:IN_REGION():+> region;
    return region;
}

def add_tradition(region: Region, key: str, name: str) -> CulinaryTradition {
    tradition = CulinaryTradition(key=key, name=name);
    tradition +>:PART_OF():+> region;
    return tradition;
}

def add_recipe(
    tradition: CulinaryTradition, key: str, name: str, description: str, minutes: int
) -> Recipe {
    recipe = Recipe(
        key=key, name=name, description=description, minutes=minutes, servings=2
    );
    recipe +>:BELONGS_TO():+> tradition;
    return recipe;
}

def require(
    recipe: Recipe,
    ingredient: Ingredient,
    quantity: float,
    unit: str,
    essential: bool = True,
    preparation: str = "",
    substitution: str = "",
    substitutes: list[str] = []
) {
    recipe +>:REQUIRES(
        quantity=quantity,
        unit=unit,
        essential=essential,
        preparation=preparation,
        substitution_notes=substitution,
        substitutes=substitutes
    ):+> ingredient;
}

def add_steps(recipe: Recipe, first: str, second: str) {
    # Deliberately insert in reverse order to exercise relationship-based ordering.
    recipe +>:HAS_STEP(sequence=2):+> RecipeStep(instruction=second);
    recipe +>:HAS_STEP(sequence=1):+> RecipeStep(instruction=first);
}

def build_demo_graph() -> CulinaryCatalogue {
    catalogue = CulinaryCatalogue();
    africa = add_region(
        catalogue,
        "east-africa",
        "East Africa",
        "Explore Kenyan and Tanzanian demo kitchens.",
        "❋",
        "terracotta"
    );
    asia = add_region(
        catalogue,
        "east-asia",
        "East Asia",
        "Explore Korean and Japanese demo kitchens.",
        "◒",
        "sage"
    );
    south = add_region(
        catalogue,
        "south-asia",
        "South Asia",
        "Explore Indian and Sri Lankan demo kitchens.",
        "✷",
        "saffron"
    );
    med = add_region(
        catalogue,
        "mediterranean",
        "The Mediterranean",
        "Explore Greek and Turkish demo kitchens.",
        "☼",
        "lavender"
    );
    kenyan = add_tradition(africa, "kenyan", "Kenyan");
    tanzanian = add_tradition(africa, "tanzanian", "Tanzanian");
    korean = add_tradition(asia, "korean", "Korean");
    japanese = add_tradition(asia, "japanese", "Japanese");
    indian = add_tradition(south, "indian", "Indian");
    sri_lankan = add_tradition(south, "sri-lankan", "Sri Lankan");
    greek = add_tradition(med, "greek", "Greek");
    turkish = add_tradition(med, "turkish", "Turkish");
    # Shared ingredient identities demonstrate reuse across multiple recipes.
    oil = Ingredient(name="cooking oil");
    onion = Ingredient(name="onion");
    tomato = Ingredient(name="tomato");
    potato = Ingredient(name="potato");
    spinach = Ingredient(name="spinach");
    egg = Ingredient(name="egg");
    salt = Ingredient(name="salt");
    kale = Ingredient(name="kale");
    coconut = Ingredient(name="coconut milk");
    soy = Ingredient(name="soy sauce");
    lentil = Ingredient(name="red lentil");
    turmeric = Ingredient(name="turmeric");
    chickpea = Ingredient(name="cooked chickpea");
    lemon = Ingredient(name="lemon juice");
    pepper = Ingredient(name="green pepper");
    cumin = Ingredient(name="cumin");

    sukuma = add_recipe(
        kenyan,
        "sukuma-wiki-demo",
        "Sukuma wiki",
        "A simple kale-and-tomato demo adaptation.",
        20
    );
    require(
        sukuma,
        kale,
        300.0,
        "g",
        preparation="sliced",
        substitutes=["spinach", "collard greens"]
    );
    require(sukuma, onion, 100.0, "g", preparation="chopped");
    require(sukuma, tomato, 150.0, "g", preparation="chopped");
    require(sukuma, oil, 15.0, "ml");
    require(sukuma, salt, 2.0, "g", essential=False);
    add_steps(
        sukuma,
        "Prepare and wash the greens; chop the onion and tomato.",
        "Soften onion in oil, add tomato, then cook the greens until tender."
    );

    mchicha = add_recipe(
        tanzanian,
        "mchicha-demo",
        "Mchicha",
        "Spinach in coconut milk, shown as an illustrative adaptation.",
        25
    );
    require(
        mchicha,
        spinach,
        300.0,
        "g",
        preparation="washed",
        substitution="Other tender leafy greens may work; cooking times vary.",
        substitutes=["kale"]
    );
    require(mchicha, coconut, 200.0, "ml");
    require(mchicha, onion, 100.0, "g");
    require(mchicha, oil, 10.0, "ml");
    add_steps(
        mchicha,
        "Wash spinach and chop the onion.",
        "Soften onion, add coconut milk and spinach, and simmer until tender."
    );

    pancake = add_recipe(
        korean,
        "gamja-jeon-demo",
        "Gamja-jeon",
        "A potato pancake demo; quantities are fixture data.",
        25
    );
    require(pancake, potato, 300.0, "g", preparation="peeled and grated");
    require(pancake, oil, 15.0, "ml");
    require(pancake, salt, 2.0, "g", essential=False);
    add_steps(
        pancake,
        "Grate the potato and drain excess water.",
        "Form a thin pancake and pan-fry in oil until cooked through and golden."
    );

    omelette = add_recipe(
        japanese,
        "tamagoyaki-demo",
        "Tamagoyaki",
        "A simplified rolled-egg demo adaptation.",
        15
    );
    require(omelette, egg, 4.0, "piece");
    require(omelette, oil, 10.0, "ml");
    require(omelette, soy, 5.0, "ml", essential=False);
    add_steps(
        omelette,
        "Beat eggs with the optional seasoning.",
        "Cook thin layers in a lightly oiled pan, rolling each layer; cook eggs through."
    );

    palak = add_recipe(
        indian,
        "aloo-palak-demo",
        "Aloo palak",
        "An illustrative potato-and-spinach adaptation.",
        30
    );
    require(palak, potato, 300.0, "g", preparation="diced");
    require(palak, spinach, 200.0, "g");
    require(palak, onion, 100.0, "g");
    require(palak, cumin, 2.0, "g");
    require(palak, oil, 15.0, "ml");
    add_steps(
        palak,
        "Wash the spinach and dice potatoes into small pieces.",
        "Cook onion and cumin in oil, add potato and water as needed, then spinach; cook until tender."
    );

    dal = add_recipe(
        sri_lankan,
        "parippu-demo",
        "Parippu",
        "A coconut-and-lentil demo adaptation, not a verified traditional formula.",
        30
    );
    require(dal, lentil, 150.0, "g", preparation="rinsed");
    require(dal, coconut, 200.0, "ml");
    require(dal, onion, 75.0, "g");
    require(dal, turmeric, 1.0, "g", essential=False);
    add_steps(
        dal,
        "Rinse lentils and prepare the onion.",
        "Simmer lentils in water until tender, add coconut milk and onion, and finish cooking."
    );

    stew = add_recipe(
        greek,
        "revithia-demo",
        "Revithia",
        "A cooked-chickpea stew demo with lemon.",
        35
    );
    require(stew, chickpea, 400.0, "g", preparation="already cooked");
    require(stew, onion, 100.0, "g");
    require(stew, oil, 15.0, "ml");
    require(stew, lemon, 15.0, "ml", essential=False);
    add_steps(
        stew,
        "Drain the cooked chickpeas and chop onion.",
        "Soften onion in oil, add chickpeas and water, simmer and finish with optional lemon."
    );

    menemen = add_recipe(
        turkish,
        "menemen-demo",
        "Menemen",
        "A tomato, pepper and egg demo adaptation.",
        20
    );
    require(menemen, egg, 3.0, "piece");
    require(menemen, tomato, 250.0, "g", preparation="chopped");
    require(menemen, pepper, 100.0, "g");
    require(menemen, oil, 15.0, "ml");
    add_steps(
        menemen,
        "Chop tomato and pepper.",
        "Soften pepper in oil, add tomato, then eggs; cook eggs through."
    );
    # Keep reverse-linked sources reachable from the transient catalogue itself.
    # Otherwise their Python object lifetimes can end after the builder returns.
    for tradition in [
        kenyan,
        tanzanian,
        korean,
        japanese,
        indian,
        sri_lankan,
        greek,
        turkish
    ] {
        catalogue +>:CATALOGUE_TRADITION():+> tradition;
    }
    for recipe in [sukuma, mchicha, pancake, omelette, palak, dal, stew, menemen] {
        catalogue +>:CATALOGUE_RECIPE():+> recipe;
    }
    return catalogue;
}
