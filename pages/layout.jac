import from "@jac/runtime" { Outlet, Link, useLocation }
import from ..components.ConnectionStatus { ConnectionStatus }

def:pub Shell() -> JsxLayout {
    location = useLocation();
    return
        <div className="site-shell">
            <a className="skip-link" href="#main-content">Skip to content</a>
            <header className="site-header">
                <Link to="/" className="brand" aria-label="Cooksy home">
                    <span className="brand-mark" aria-hidden="true">
                        c
                        <span></span>
                    </span>
                    cooksy
                    <span className="brand-period">.</span>
                </Link>
                <nav aria-label="Main navigation" className="main-nav">
                    <Link
                        to="/"
                        className={"nav-link active"
                            if location.pathname == "/"
                            else "nav-link"}
                        aria-current={"page" if location.pathname == "/" else None}
                    >
                        Home
                    </Link>
                    <Link
                        to="/explore"
                        className={"nav-link active"
                            if location.pathname == "/explore"
                            else "nav-link"}
                        aria-current={"page"
                            if location.pathname == "/explore"
                            else None}
                    >
                        Explore
                    </Link>
                    <Link
                        to="/cook-along"
                        className={"nav-link active"
                            if location.pathname == "/cook-along"
                            else "nav-link"}
                        aria-current={"page"
                            if location.pathname == "/cook-along"
                            else None}
                    >
                        Cook along
                    </Link>
                </nav>
                <Link
                    to="/pantry"
                    className="pantry-link"
                    aria-current={"page" if location.pathname == "/pantry" else None}
                >
                    <span aria-hidden="true">+</span>{" "}
                    My pantry
                </Link>
            </header>
            <div className="demo-banner">
                <span className="demo-badge">DEVELOPMENT PREVIEW</span>
                <span>
                    A little taste of Cooksy. Browse demo recipes. Pantry matching and guided cooking are coming next.
                </span>
            </div>
            <main id="main-content" tabIndex={-1}>
                <Outlet/>
            </main>
            <footer className="site-footer">
                <div>
                    <Link to="/" className="footer-brand">cooksy.</Link>
                    <p>Your ingredients. The world’s kitchens.</p>
                </div>
                <ConnectionStatus/>
                <span className="footer-note">Made with Jac · Demo graph preview</span>
            </footer>
        </div>;
}
