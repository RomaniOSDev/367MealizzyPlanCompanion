import Foundation

enum BrinzaRecipeAtlas {
    static let styles = ["All", "Quick", "Hearty", "Fresh", "Warm"]

    static func brinzaFind(_ id: String) -> BrinzaRecipeCard? {
        cards.first { $0.id == id }
    }

    static let cards: [BrinzaRecipeCard] = [
        BrinzaRecipeCard(
            id: "lemon-herb-bowl",
            title: "Lemon herb bowl",
            styleTag: "Fresh",
            minutes: 25,
            stillKey: BrinzaStillRack.bowl,
            blurb: "A single warm bowl with rice, greens, and lemon.",
            steps: [
                "Rinse the rice and simmer it until tender.",
                "Warm the chicken with garlic and lemon.",
                "Fold in parsley and serve in one bowl."
            ],
            ingredients: [
                BrinzaIngredientBit(id: "lhb-chicken", name: "Chicken", unitLabel: "piece", baseCount: 1, aisle: "Proteins"),
                BrinzaIngredientBit(id: "lhb-lemon", name: "Lemon", unitLabel: "piece", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "lhb-rice", name: "Rice", unitLabel: "cup", baseCount: 1, aisle: "Grains"),
                BrinzaIngredientBit(id: "lhb-parsley", name: "Parsley", unitLabel: "handful", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "lhb-garlic", name: "Garlic", unitLabel: "clove", baseCount: 2, aisle: "Pantry")
            ]
        ),
        BrinzaRecipeCard(
            id: "tomato-rice-skillet",
            title: "Tomato rice skillet",
            styleTag: "Hearty",
            minutes: 30,
            stillKey: BrinzaStillRack.board,
            blurb: "One pan of rice, tomato, and beans for a full plate.",
            steps: [
                "Soften onion in a small skillet.",
                "Add rice, tomato, and beans with a splash of water.",
                "Cover and cook until the rice is tender."
            ],
            ingredients: [
                BrinzaIngredientBit(id: "trs-tomato", name: "Tomato", unitLabel: "piece", baseCount: 2, aisle: "Produce"),
                BrinzaIngredientBit(id: "trs-rice", name: "Rice", unitLabel: "cup", baseCount: 1, aisle: "Grains"),
                BrinzaIngredientBit(id: "trs-onion", name: "Onion", unitLabel: "piece", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "trs-beans", name: "Beans", unitLabel: "cup", baseCount: 1, aisle: "Proteins"),
                BrinzaIngredientBit(id: "trs-oil", name: "Olive oil", unitLabel: "spoon", baseCount: 1, aisle: "Pantry")
            ]
        ),
        BrinzaRecipeCard(
            id: "garlic-greens-pasta",
            title: "Garlic greens pasta",
            styleTag: "Quick",
            minutes: 20,
            stillKey: BrinzaStillRack.noodles,
            blurb: "A small pot of pasta with spinach and garlic.",
            steps: [
                "Boil pasta until just tender.",
                "Warm garlic, then wilt the spinach.",
                "Toss the pasta with the greens and cheese."
            ],
            ingredients: [
                BrinzaIngredientBit(id: "ggp-pasta", name: "Pasta", unitLabel: "cup", baseCount: 1, aisle: "Grains"),
                BrinzaIngredientBit(id: "ggp-garlic", name: "Garlic", unitLabel: "clove", baseCount: 3, aisle: "Pantry"),
                BrinzaIngredientBit(id: "ggp-spinach", name: "Spinach", unitLabel: "handful", baseCount: 2, aisle: "Produce"),
                BrinzaIngredientBit(id: "ggp-cheese", name: "Hard cheese", unitLabel: "handful", baseCount: 1, aisle: "Dairy")
            ]
        ),
        BrinzaRecipeCard(
            id: "yogurt-berry-cup",
            title: "Yogurt berry cup",
            styleTag: "Fresh",
            minutes: 10,
            stillKey: BrinzaStillRack.herbs,
            blurb: "Cold yogurt with berries and oats, ready in one cup.",
            steps: [
                "Spoon yogurt into a cup.",
                "Add berries and oats.",
                "Finish with a spoon of honey."
            ],
            ingredients: [
                BrinzaIngredientBit(id: "ybc-yogurt", name: "Yogurt", unitLabel: "cup", baseCount: 1, aisle: "Dairy"),
                BrinzaIngredientBit(id: "ybc-berries", name: "Berries", unitLabel: "cup", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "ybc-oats", name: "Oats", unitLabel: "cup", baseCount: 1, aisle: "Grains"),
                BrinzaIngredientBit(id: "ybc-honey", name: "Honey", unitLabel: "spoon", baseCount: 1, aisle: "Pantry")
            ]
        ),
        BrinzaRecipeCard(
            id: "bean-pepper-stew",
            title: "Bean pepper stew",
            styleTag: "Hearty",
            minutes: 35,
            stillKey: BrinzaStillRack.bowl,
            blurb: "A small pot of beans, pepper, and tomato.",
            steps: [
                "Cook onion and pepper until soft.",
                "Add beans, tomato, and broth.",
                "Simmer until the stew looks thick."
            ],
            ingredients: [
                BrinzaIngredientBit(id: "bps-beans", name: "Beans", unitLabel: "cup", baseCount: 1, aisle: "Proteins"),
                BrinzaIngredientBit(id: "bps-pepper", name: "Pepper", unitLabel: "piece", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "bps-tomato", name: "Tomato", unitLabel: "piece", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "bps-onion", name: "Onion", unitLabel: "piece", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "bps-broth", name: "Broth", unitLabel: "cup", baseCount: 1, aisle: "Pantry")
            ]
        ),
        BrinzaRecipeCard(
            id: "egg-veggie-skillet",
            title: "Egg veggie skillet",
            styleTag: "Quick",
            minutes: 15,
            stillKey: BrinzaStillRack.board,
            blurb: "Eggs with spinach and tomato, plus a slice of bread.",
            steps: [
                "Wilt spinach with tomato.",
                "Add eggs and cook until set.",
                "Serve with the bread."
            ],
            ingredients: [
                BrinzaIngredientBit(id: "evs-eggs", name: "Eggs", unitLabel: "piece", baseCount: 2, aisle: "Proteins"),
                BrinzaIngredientBit(id: "evs-spinach", name: "Spinach", unitLabel: "handful", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "evs-tomato", name: "Tomato", unitLabel: "piece", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "evs-bread", name: "Bread", unitLabel: "slice", baseCount: 1, aisle: "Grains")
            ]
        ),
        BrinzaRecipeCard(
            id: "apple-oat-bowl",
            title: "Apple oat bowl",
            styleTag: "Warm",
            minutes: 12,
            stillKey: BrinzaStillRack.herbs,
            blurb: "Warm oats with apple and cinnamon.",
            steps: [
                "Simmer oats with milk.",
                "Stir in chopped apple and cinnamon.",
                "Rest one minute, then eat."
            ],
            ingredients: [
                BrinzaIngredientBit(id: "aob-oats", name: "Oats", unitLabel: "cup", baseCount: 1, aisle: "Grains"),
                BrinzaIngredientBit(id: "aob-apple", name: "Apple", unitLabel: "piece", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "aob-cinnamon", name: "Cinnamon", unitLabel: "pinch", baseCount: 1, aisle: "Pantry"),
                BrinzaIngredientBit(id: "aob-milk", name: "Milk", unitLabel: "cup", baseCount: 1, aisle: "Dairy")
            ]
        ),
        BrinzaRecipeCard(
            id: "miso-noodle-cup",
            title: "Miso noodle cup",
            styleTag: "Warm",
            minutes: 18,
            stillKey: BrinzaStillRack.noodles,
            blurb: "Noodles, greens, and egg in a warm cup.",
            steps: [
                "Boil noodles with carrot.",
                "Stir miso into a little hot water and add it.",
                "Top with greens and the egg."
            ],
            ingredients: [
                BrinzaIngredientBit(id: "mnc-noodles", name: "Noodles", unitLabel: "cup", baseCount: 1, aisle: "Grains"),
                BrinzaIngredientBit(id: "mnc-miso", name: "Miso", unitLabel: "spoon", baseCount: 1, aisle: "Pantry"),
                BrinzaIngredientBit(id: "mnc-greens", name: "Greens", unitLabel: "handful", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "mnc-egg", name: "Egg", unitLabel: "piece", baseCount: 1, aisle: "Proteins"),
                BrinzaIngredientBit(id: "mnc-carrot", name: "Carrot", unitLabel: "piece", baseCount: 1, aisle: "Produce")
            ]
        ),
        BrinzaRecipeCard(
            id: "chickpea-lemon-skillet",
            title: "Chickpea lemon skillet",
            styleTag: "Hearty",
            minutes: 22,
            stillKey: BrinzaStillRack.board,
            blurb: "One skillet of chickpeas, tomato, and lemon.",
            steps: [
                "Warm onion and garlic in the skillet.",
                "Add chickpeas and tomato and simmer until thick.",
                "Finish with lemon and parsley."
            ],
            ingredients: [
                BrinzaIngredientBit(id: "cls-chickpeas", name: "Chickpeas", unitLabel: "cup", baseCount: 1, aisle: "Proteins"),
                BrinzaIngredientBit(id: "cls-tomato", name: "Tomato", unitLabel: "piece", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "cls-onion", name: "Onion", unitLabel: "piece", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "cls-lemon", name: "Lemon", unitLabel: "piece", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "cls-parsley", name: "Parsley", unitLabel: "handful", baseCount: 1, aisle: "Produce")
            ]
        ),
        BrinzaRecipeCard(
            id: "mushroom-toast",
            title: "Mushroom toast",
            styleTag: "Quick",
            minutes: 14,
            stillKey: BrinzaStillRack.herbs,
            blurb: "Toast with garlicky mushrooms and a little cheese.",
            steps: [
                "Toast the bread.",
                "Cook mushrooms with garlic until browned.",
                "Pile them on the toast with cheese."
            ],
            ingredients: [
                BrinzaIngredientBit(id: "mto-bread", name: "Bread", unitLabel: "slice", baseCount: 2, aisle: "Grains"),
                BrinzaIngredientBit(id: "mto-mushroom", name: "Mushrooms", unitLabel: "cup", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "mto-garlic", name: "Garlic", unitLabel: "clove", baseCount: 1, aisle: "Pantry"),
                BrinzaIngredientBit(id: "mto-cheese", name: "Hard cheese", unitLabel: "handful", baseCount: 1, aisle: "Dairy")
            ]
        ),
        BrinzaRecipeCard(
            id: "tuna-rice-plate",
            title: "Tuna rice plate",
            styleTag: "Fresh",
            minutes: 16,
            stillKey: BrinzaStillRack.bowl,
            blurb: "Rice, tuna, cucumber, and lemon on one plate.",
            steps: [
                "Warm or cook the rice.",
                "Slice the cucumber.",
                "Plate the tuna with lemon and a spoon of yogurt."
            ],
            ingredients: [
                BrinzaIngredientBit(id: "trp-rice", name: "Rice", unitLabel: "cup", baseCount: 1, aisle: "Grains"),
                BrinzaIngredientBit(id: "trp-tuna", name: "Tuna", unitLabel: "piece", baseCount: 1, aisle: "Proteins"),
                BrinzaIngredientBit(id: "trp-cucumber", name: "Cucumber", unitLabel: "piece", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "trp-lemon", name: "Lemon", unitLabel: "piece", baseCount: 1, aisle: "Produce"),
                BrinzaIngredientBit(id: "trp-yogurt", name: "Yogurt", unitLabel: "spoon", baseCount: 1, aisle: "Dairy")
            ]
        ),
        BrinzaRecipeCard(
            id: "cocoa-oat-cup",
            title: "Cocoa oat cup",
            styleTag: "Warm",
            minutes: 8,
            stillKey: BrinzaStillRack.noodles,
            blurb: "A small warm cup of oats, cocoa, and milk.",
            steps: [
                "Simmer oats with milk.",
                "Stir in cocoa and honey.",
                "Rest one minute, then eat."
            ],
            ingredients: [
                BrinzaIngredientBit(id: "coc-oats", name: "Oats", unitLabel: "cup", baseCount: 1, aisle: "Grains"),
                BrinzaIngredientBit(id: "coc-milk", name: "Milk", unitLabel: "cup", baseCount: 1, aisle: "Dairy"),
                BrinzaIngredientBit(id: "coc-cocoa", name: "Cocoa", unitLabel: "spoon", baseCount: 1, aisle: "Pantry"),
                BrinzaIngredientBit(id: "coc-honey", name: "Honey", unitLabel: "spoon", baseCount: 1, aisle: "Pantry")
            ]
        )
    ]
}

enum BrinzaRecipeAtlasKelvDrift {
    static func brinzaRecipeAtlasKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "ehxyynpqhabwvm-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 8) &+ Int(scalar.value)
        }
    }
}
