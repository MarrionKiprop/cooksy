import from "@jac/runtime" { Link }

def:pub NotFound() -> JsxPage {
    return
        <div className="page-width not-found">
            <span className="eyebrow">A LITTLE DETOUR · 404</span>
            <h1>
                This kitchen
                <br/>
                <em>isn’t on the map.</em>
            </h1>
            <p>Let’s get you back to somewhere delicious.</p>
            <Link to="/" className="button primary">
                Back to Cooksy{" "}
                <span aria-hidden="true">→</span>
            </Link>
        </div>;
}
