"""Navigation metadata only: 15 culinary lenses, not a static recipe database."""
import from graph.models {
    CulinaryCatalogue,
    Region,
    CulinaryTradition,
    IN_REGION,
    PART_OF,
    CATALOGUE_TRADITION
}
import from graph.seed { add_region, add_tradition }
import from .views { NavigationCatalogue }
import from graph.views { RegionView, TraditionView }

glob REGION_DATA: list[tuple[str, str, str, list[tuple[str, str]]]] = [
         (
             "east-africa",
             "East Africa",
             "Explore coastal, highland and inland kitchens.",
             [
                 ("kenyan", "Kenyan"),
                 ("tanzanian", "Tanzanian"),
                 ("ethiopian", "Ethiopian")
             ]
         ),
         (
             "north-africa",
             "North Africa",
             "Meet distinct Maghrebi and Egyptian traditions.",
             [
                 ("moroccan", "Moroccan"),
                 ("egyptian", "Egyptian"),
                 ("tunisian", "Tunisian")
             ]
         ),
         (
             "west-africa",
             "West Africa",
             "Explore diverse grain, vegetable and stew traditions.",
             [
                 ("nigerian", "Nigerian"),
                 ("ghanaian", "Ghanaian"),
                 ("senegalese", "Senegalese")
             ]
         ),
         (
             "southern-africa",
             "Southern Africa",
             "Discover kitchens across the southern continent.",
             [
                 ("south-african", "South African"),
                 ("zimbabwean", "Zimbabwean"),
                 ("mozambican", "Mozambican")
             ]
         ),
         (
             "middle-east",
             "Middle East",
             "Explore distinct Levantine, Anatolian and Persian kitchens.",
             [
                 ("levantine", "Levantine"),
                 ("turkish", "Turkish"),
                 ("persian", "Persian")
             ]
         ),
         (
             "south-asia",
             "South Asia",
             "Explore regional preparations across South Asia.",
             [
                 ("indian", "Indian"),
                 ("sri-lankan", "Sri Lankan"),
                 ("pakistani", "Pakistani")
             ]
         ),
         (
             "east-asia",
             "East Asia",
             "Discover Korean, Japanese and Chinese traditions.",
             [("korean", "Korean"), ("japanese", "Japanese"), ("chinese", "Chinese")]
         ),
         (
             "southeast-asia",
             "Southeast Asia",
             "Explore mainland and island kitchens.",
             [
                 ("thai", "Thai"),
                 ("vietnamese", "Vietnamese"),
                 ("indonesian", "Indonesian")
             ]
         ),
         (
             "central-asia",
             "Central Asia",
             "Meet distinct Central Asian cooking traditions.",
             [("uzbek", "Uzbek"), ("kazakh", "Kazakh"), ("kyrgyz", "Kyrgyz")]
         ),
         (
             "mediterranean",
             "Mediterranean",
             "Explore coastal preparations through specific traditions.",
             [("greek", "Greek"), ("italian", "Italian"), ("spanish", "Spanish")]
         ),
         (
             "western-europe",
             "Western Europe",
             "Discover regional European home cooking.",
             [("french", "French"), ("german", "German"), ("british", "British")]
         ),
         (
             "eastern-europe",
             "Eastern Europe",
             "Explore distinct eastern European kitchens.",
             [
                 ("polish", "Polish"),
                 ("ukrainian", "Ukrainian"),
                 ("romanian", "Romanian")
             ]
         ),
         (
             "latin-america",
             "Latin America",
             "Explore Mexican, Central and South American traditions.",
             [
                 ("mexican", "Mexican"),
                 ("peruvian", "Peruvian"),
                 ("brazilian", "Brazilian")
             ]
         ),
         (
             "north-america",
             "North America",
             "Explore regional traditions across North America.",
             [
                 ("us-southern", "US Southern"),
                 ("cajun", "Cajun"),
                 ("canadian", "Canadian")
             ]
         ),
         (
             "caribbean",
             "Caribbean",
             "Discover distinct island cooking traditions.",
             [
                 ("jamaican", "Jamaican"),
                 ("cuban", "Cuban"),
                 ("trinidadian", "Trinidadian")
             ]
         )
     ];

def plain(text: str) -> str {
    return " ".join(
        text.lower().replace("-inspired", "").replace(" inspired", "").replace(
            "-style", ""
        ).replace(
            " style", ""
        ).replace(
            "the ", ""
        ).replace(
            "-", " "
        ).split()
    );
}

def region_identity(region: str, tradition: str) -> str {
    for row in REGION_DATA {
        for item in row[3] {
            if plain(tradition) in [plain(item[0]), plain(item[1])] {
                return row[0];
            }
        }
    }
    for row in REGION_DATA {
        if plain(region) in [plain(row[0]), plain(row[1])] {
            return row[0];
        }
    }
    return "";
}

def region_name(key: str) -> str {
    for row in REGION_DATA {
        if row[0] == key {
            return row[1];
        }
    }
    return "";
}

def tradition_name(region_key: str, tradition_key: str) -> str {
    for row in REGION_DATA {
        if row[0] == region_key {
            for item in row[3] {
                if item[0] == tradition_key {
                    return item[1];
                }
            }
        }
    }
    return "";
}

def in_scope(region: str, tradition: str, region_key: str, tradition_key: str) -> bool {
    actual = region_identity(region, tradition);
    if not actual or (region_key and actual != region_key) {
        return False;
    }
    return not tradition_key
        or plain(tradition) == plain(tradition_name(region_key, tradition_key));
}

def validate_scope(mode: str, region_key: str, tradition_key: str) -> None {
    if mode not in ["explore", "discover"] {
        raise ValueError("Unknown discovery mode");
    }
    if mode == "discover" and (region_key or tradition_key) {
        raise ValueError("Discover is worldwide; clear the regional scope");
    }
    if region_key and not region_name(region_key) {
        raise ValueError("Unknown culinary region");
    }
    if tradition_key and not tradition_name(region_key, tradition_key) {
        raise ValueError("Tradition does not belong to selected region");
    }
}

def build_taxonomy() -> CulinaryCatalogue {
    catalogue = CulinaryCatalogue();
    tones = ["terracotta", "sage", "saffron", "lavender"];
    motifs = ["✳", "◒", "✷", "☼"];
    for index in range(len(REGION_DATA)) {
        row = REGION_DATA[index];
        region = add_region(
            catalogue, row[0], row[1], row[2], motifs[index % 4], tones[index % 4]
        );
        for item in row[3] {
            tradition = add_tradition(region, item[0], item[1]);
            catalogue +>:CATALOGUE_TRADITION():+> tradition;
        }
    }
    return catalogue;
}

walker NavigationWalker {
    has regions: list[RegionView] = [],
        traditions: list[TraditionView] = [];

    can start with CulinaryCatalogue entry {
        visit [here->:IN_REGION:->];
    }

    can region with Region entry {
        self.regions.append(
            RegionView(
                key=here.key,
                name=here.name,
                subtitle=here.subtitle,
                motif=here.motif,
                tone=here.tone
            )
        );
        visit [here<-:PART_OF:<-];
    }

    can tradition with CulinaryTradition entry {
        region = [here->:PART_OF:->][0];
        self.traditions.append(
            TraditionView(key=here.key, name=here.name, region_key=region.key)
        );
    }
}

def navigation() -> NavigationCatalogue {
    walker_result = build_taxonomy() spawn NavigationWalker();
    return NavigationCatalogue(
        regions=walker_result.regions, traditions=walker_result.traditions
    );
}
