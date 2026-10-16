import from endpoints { shell_status }

def:pub ConnectionStatus() -> JsxElement {
    has message: str = "Checking the Jac kitchen…",
        checking: bool = True,
        failed: bool = False;

    async def checkConnection {
        checking = True;
        failed = False;
        message = "Checking the Jac kitchen…";
        try {
            message = await shell_status();
        } except Exception {
            message = "The kitchen is offline. Try connecting again.";
            failed = True;
        }
        checking = False;
    }

    async can with entry {
        await checkConnection();
    }

    return
        <div className="connection">
            <span
                className={"status-dot offline" if failed else "status-dot"}
                aria-hidden="true"
            ></span>
            <span role="status">{message}</span>
            <button
                className="text-button"
                type="button"
                onClick={checkConnection}
                disabled={checking}
            >
                {"Checking…" if checking else "Reconnect"}
            </button>
        </div>;
}
