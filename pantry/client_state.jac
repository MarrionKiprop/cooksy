"""One confirmed pantry per browser tab, with route-memory fallback."""
glob pantry_memory: list[str] = [],
     pantry_loaded: bool = False,
     choices_memory: str = "",
     scope_memory: str = "";

def:pub read_pantry() -> list[str] {
    if not pantry_loaded {
        try {
            stored = (sessionStorage.getItem("cooksy.pantry.v1") or "") as str;
            pantry_memory = stored.split("|") if stored else [];
        } except Exception {
            pantry_memory = [];
        }
        pantry_loaded = True;
    }
    return pantry_memory;
}

def:pub clear_choices() -> None {
    choices_memory = "";
    try {
        sessionStorage.removeItem("cooksy.choices.v1");
    } except Exception {}
}

def:pub write_pantry(names: list[str]) -> bool {
    if "|".join(names) != "|".join(read_pantry()) {
        clear_choices();
    }
    pantry_memory = names;
    pantry_loaded = True;
    try {
        sessionStorage.setItem("cooksy.pantry.v1", "|".join(names));
        return True;
    } except Exception {
        return False;
    }
}

def:pub read_scope() -> str {
    if scope_memory {
        return scope_memory;
    }
    try {
        scope_memory = (sessionStorage.getItem("cooksy.scope.v1") or "") as str;
    } except Exception {}
    return scope_memory;
}

def:pub write_scope(value: str) -> None {
    scope_memory = value;
    try {
        sessionStorage.setItem("cooksy.scope.v1", value);
    } except Exception {}
}

def:pub save_choices(context: str, keys: list[str]) -> None {
    choices_memory = context + "~" + "|".join(keys);
    try {
        sessionStorage.setItem("cooksy.choices.v1", choices_memory);
    } except Exception {}
}

def:pub read_choices(context: str) -> list[str] {
    if not choices_memory {
        try {
            choices_memory = (sessionStorage.getItem("cooksy.choices.v1") or "") as str;
        } except Exception {}
    }
    pieces = choices_memory.split("~");
    if len(pieces) == 2 and pieces[0] == context {
        return pieces[1].split("|");
    }
    return [];
}
