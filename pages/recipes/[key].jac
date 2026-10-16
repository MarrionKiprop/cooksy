import from "@jac/runtime" { useParams }
import from ...cooking.RecipeDetail { RecipeDetail }

def:pub RecipePage() -> JsxPage {
    params = useParams();
    recipe_key = (params["key"] or "") as str;
    return <RecipeDetail recipeKey={recipe_key}/>;
}
