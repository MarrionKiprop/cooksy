def:pub RegionCard(
    name: str,
    subtitle: str,
    motif: str,
    tone: str,
    selected: bool,
    onSelect: Callable[[MouseEvent], None]
) -> JsxElement {
    return
        <button
            type="button"
            className={"region-card " + tone + (" selected" if selected else "")}
            aria-pressed={selected}
            onClick={onSelect}
        >
            <div className="region-art" aria-hidden="true">
                <span className="region-ring"></span>
                <span className="region-motif">{motif}</span>
                <span className="region-speck">✳</span>
            </div>
            <div className="region-copy">
                <span className="region-label">A PLACE TO BEGIN</span>
                <h2>{name}</h2>
                <p>{subtitle}</p>
                <span className="region-arrow" aria-hidden="true">↗</span>
            </div>
        </button>;
}
