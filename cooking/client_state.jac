"""One versioned active session per browser tab, with route-level memory fallback."""
import type from .views { CookingView }
glob session_memory: str = "";

def:pub read_session() -> str {
    if session_memory {
        return session_memory;
    }
    try {
        return (sessionStorage.getItem("cooksy.cooking.v1") or "") as str;
    } except Exception {
        return "";
    }
}

def:pub save_session(state: CookingView) -> bool {
    session_memory = state.version
        + "|"
        + state.recipe_key
        + "|"
        + str(state.current_sequence)
        + "|"
        + ("1" if state.finished else "0");
    try {
        sessionStorage.setItem("cooksy.cooking.v1", session_memory);
        return True;
    } except Exception {
        return False;
    }
}

def:pub clear_session() -> bool {
    session_memory = "";
    try {
        sessionStorage.removeItem("cooksy.cooking.v1");
        return True;
    } except Exception {
        return False;
    }
}
