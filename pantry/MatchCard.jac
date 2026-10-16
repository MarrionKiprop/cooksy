import from "@jac/runtime" { Link }
import from .views { MatchView }

def:pub MatchCard(candidate: MatchView) -> JsxElement {
    return
        <article className="match-card">
            <div className="seed-meta">
                <span>
                    {candidate.recipe.tradition} · {candidate.recipe.minutes} min
                </span>
                <span className="coverage-badge">
                    {candidate.score}% essential coverage
                </span>
            </div>
            <span className="small-tag">{candidate.recipe.verification}</span>
            <h3>{candidate.recipe.name}</h3>
            <p className="match-readiness">
                {"Essential ingredient types present"
                    if not candidate.missing_essential
                    else str(len(candidate.missing_essential))
                        + " essential ingredient types missing"}
            </p>
            <p className="match-explanation">{candidate.explanation}</p>
            <div className="match-columns">
                <div>
                    <h4>In your pantry</h4>
                    <p>
                        {", ".join([item.name for item in candidate.available])
                            if candidate.available
                            else "None of the required types yet"}
                    </p>
                </div>
                <div>
                    <h4>Still needed</h4>
                    <p>
                        {", ".join([item.name for item in candidate.missing_essential])
                            if candidate.missing_essential
                            else "No essential types missing"}
                    </p>
                </div>
            </div>
            <Link to={"/recipes/" + candidate.recipe.key} className="inline-link">
                View recipe →
            </Link>
            <details>
                <summary>Why this match?</summary>
                <p className="fixture-note">
                    Optional missing: {", ".join(
                        [item.name for item in candidate.missing_optional]
                    )
                        if candidate.missing_optional
                        else "none"}.
                </p>
                <p className="fixture-note">
                    Only directly available essential ingredient types contribute to the score. Your amounts have not been checked.
                </p>
                <ul className="substitution-list">
                    {[
                        <li key={item.required + item.alternative}>
                            Possible swap: {item.alternative} for {item.required}. {item.note} The required ingredient stays marked missing.
                        </li> for item in candidate.substitutions
                    ]}
                </ul>
                <p className="fixture-note">
                    {candidate.recipe.verification}. {candidate.recipe.provenance}.
                </p>
            </details>
        </article>;
}
