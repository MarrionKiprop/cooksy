import type from .views { CandidateView }

def:pub CandidateCard(
    candidate: CandidateView, busy: bool, onSelect: Callable[[MouseEvent], None]
) -> JsxElement {
    return
        <article className="ai-candidate">
            <span className="small-tag">{candidate.verification}</span>
            <h3>{candidate.name}</h3>
            <p>{candidate.description}</p>
            <p>
                {candidate.region
                    + " · "
                    + candidate.tradition
                    + " · about "
                    + str(candidate.minutes)
                    + " min"}
            </p>
            <p>{str(candidate.score) + "% direct essential ingredient coverage"}</p>
            <p>
                {"Missing essentials: " + ", ".join(candidate.missing)
                    if len(candidate.missing)
                    else "All named essential ingredients available"}
            </p>
            <p className="fixture-note">{candidate.provenance}</p>
            <button
                type="button"
                className="button secondary"
                disabled={busy}
                onClick={onSelect}
            >
                {"View prepared recipe"
                    if candidate.prepared
                    else "Prepare this recipe"}
            </button>
        </article>;
}
