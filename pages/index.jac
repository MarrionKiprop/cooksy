import from "@jac/runtime" { Link }

def:pub Home() -> JsxPage {
    return
        <div>
            <section className="hero page-width" aria-labelledby="hero-title">
                <div className="hero-copy">
                    <span className="eyebrow">
                        <span aria-hidden="true">✳</span>{" "}
                        A LITTLE PANTRY. A WORLD OF POSSIBILITY.
                    </span>
                    <h1 id="hero-title">
                        Good food starts
                        <br/>
                        with what
                        <br/>
                        you{" "}
                        <em>already have.</em>
                    </h1>
                    <p className="hero-description">
                        A few ingredients. A new corner of the world. Find your next kitchen adventure with Cooksy.
                    </p>
                    <div className="hero-actions">
                        <Link to="/pantry" className="button primary">
                            Open my pantry{" "}
                            <span aria-hidden="true">↗</span>
                        </Link>
                        <Link to="/explore" className="button secondary">
                            Explore the world{" "}
                            <span aria-hidden="true">→</span>
                        </Link>
                    </div>
                    <div className="hero-caption">
                        <span className="tiny-leaf" aria-hidden="true">❋</span>{" "}
                        Less wondering. More cooking. Less going to waste.
                    </div>
                </div>
                <div
                    className="hero-art"
                    role="img"
                    aria-label="Decorative illustration of a golden pancake on a ceramic plate with greens and tomatoes"
                >
                    <span className="art-orbit orbit-one"></span>
                    <span className="art-orbit orbit-two"></span>
                    <span className="floating-note note-top">
                        Something delicious
                        <br/>
                        <em>is already in your kitchen.</em>
                    </span>
                    <div className="plate">
                        <div className="plate-inner">
                            <div className="pancake">
                                <i></i>
                                <i></i>
                                <i></i>
                                <i></i>
                                <i></i>
                                <span className="garnish g1"></span>
                                <span className="garnish g2"></span>
                                <span className="garnish g3"></span>
                            </div>
                            <div className="tomato t1"></div>
                            <div className="tomato t2"></div>
                            <div className="salad s1"></div>
                            <div className="salad s2"></div>
                            <div className="salad s3"></div>
                        </div>
                    </div>
                    <span className="art-spark spark-one">✳</span>
                    <span className="art-spark spark-two">✧</span>
                    <div className="ingredient-note">
                        <span aria-hidden="true">↗</span>
                        <div>
                            <strong>Simple ingredients.</strong>
                            <span>Unexpected possibilities.</span>
                        </div>
                    </div>
                    <span className="art-caption">
                        A little serving inspiration · illustration
                    </span>
                </div>
            </section>
            <section className="how-section" aria-labelledby="how-title">
                <div className="page-width">
                    <div className="section-heading">
                        <div>
                            <span className="eyebrow">
                                FROM YOUR SHELF TO YOUR TABLE
                            </span>
                            <h2 id="how-title">
                                A good meal is closer than you think.
                            </h2>
                        </div>
                        <span className="section-note">The Cooksy journey</span>
                    </div>
                    <div className="journey-grid">
                        <article className="journey-card">
                            <span className="step-number">01</span>
                            <h3>Start with your pantry</h3>
                            <p>
                                Tell us what’s on hand. Photo suggestions will always be yours to confirm.
                            </p>
                            <span className="small-tag">
                                Pantry intake · coming soon
                            </span>
                        </article>
                        <article className="journey-card">
                            <span className="step-number">02</span>
                            <h3>Follow your curiosity</h3>
                            <p>
                                Explore cuisines, then see which meals fit and what you might still need.
                            </p>
                            <Link to="/explore" className="inline-link">
                                Browse the regions{" "}
                                <span aria-hidden="true">→</span>
                            </Link>
                        </article>
                        <article className="journey-card">
                            <span className="step-number">03</span>
                            <h3>Make it your own</h3>
                            <p>
                                Pick a meal and settle into a focused, one-step-at-a-time cooking experience.
                            </p>
                            <span className="small-tag">Cook along · coming soon</span>
                        </article>
                    </div>
                </div>
            </section>
            <section className="world-teaser page-width">
                <div>
                    <span className="eyebrow">SOMETHING FAMILIAR. SOMEWHERE NEW.</span>
                    <h2>
                        The world is full of
                        <br/>
                        <em>good things to cook.</em>
                    </h2>
                    <p>Start close to home, or let your curiosity take the lead.</p>
                </div>
                <Link to="/explore" className="button secondary">
                    Find your inspiration{" "}
                    <span aria-hidden="true">↗</span>
                </Link>
            </section>
        </div>;
}
