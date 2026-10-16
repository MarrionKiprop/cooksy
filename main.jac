"""Cooksy entry: file-based router children and shared visual system."""
import "./styles/global.css";

def:pub app(children: any) -> JsxElement {
    return
        <>
            <title>Cooksy — Your ingredients. The world’s kitchens.</title>
            <link
                rel="icon"
                href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Crect width='64' height='64' rx='32' fill='%23344d35'/%3E%3Ctext x='19' y='47' fill='%23f8f6ef' font-size='48' font-family='Georgia' font-style='italic'%3Ec%3C/text%3E%3C/svg%3E"
            />
            {children}
        </>;
}
