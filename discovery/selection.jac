"""Deterministic feasibility ordering and worldwide variety; no LLM ranking."""
import from ai.views { CandidateView }
import from .taxonomy { region_identity, plain }

def band(item: CandidateView) -> int {
    return 0 if len(item.missing) == 0 else (1 if len(item.missing) <= 2 else 2);
}

def choose_five(candidates: list[CandidateView], varied: bool) -> list[CandidateView] {
    ordered = sorted(
        candidates,
        key=lambda (item: CandidateView) { (
            band(item),
            len(item.missing),
            -item.score,
            item.minutes,
            item.key
        ); }
    );
    unique: list[CandidateView] = [];
    names: set[str] = set();
    for item in ordered {
        name = plain(item.name);
        if name not in names {
            unique.append(item);
            names.add(name);
        }
    }
    if not varied {
        return unique[:5];
    }
    chosen: list[CandidateView] = [];
    keys: set[str] = set();
    regions: set[str] = set();
    traditions: set[str] = set();
    # Preserve readiness bands before variety; never displace a cook-now dish for a shopping-heavy one.
    for readiness in range(3) {
        for pass_index in range(3) {
            for item in unique {
                if band(item) != readiness or item.key in keys {
                    continue;
                }
                region = region_identity(item.region, item.tradition);
                tradition = plain(item.tradition);
                if pass_index == 0 and region in regions {
                    continue;
                }
                if pass_index == 1 and tradition in traditions {
                    continue;
                }
                chosen.append(item);
                keys.add(item.key);
                regions.add(region);
                traditions.add(tradition);
                if len(chosen) == 5 {
                    return chosen;
                }
            }
        }
    }
    return chosen;
}
