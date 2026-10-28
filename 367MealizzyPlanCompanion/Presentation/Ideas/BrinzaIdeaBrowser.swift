import SwiftUI

struct BrinzaIdeaBrowser: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @State private var query = ""

    private var visible: [BrinzaRecipeCard] {
        BrinzaRecipeAtlas.cards.filter { card in
            let styleOK = vault.lastBrowsedCategory == "All" || card.styleTag == vault.lastBrowsedCategory
            let text = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let textOK = text.isEmpty || card.title.lowercased().contains(text) || card.ingredients.contains { $0.name.lowercased().contains(text) }
            return styleOK && textOK
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                BrinzaTonightCard()
                TextField("Search names or ingredients", text: $query)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(12)
                    .foregroundStyle(Color.brinzaInk)
                    .background(BrinzaTicketShape().fill(Color.brinzaCard))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(BrinzaRecipeAtlas.styles, id: \.self) { style in
                            Button(style) {
                                vault.brinzaSetCategory(style)
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(vault.lastBrowsedCategory == style ? Color.brinzaOnPrimary : Color.brinzaInk)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background {
                                if vault.lastBrowsedCategory == style {
                                    Capsule().fill(Color.brinzaBlue)
                                } else {
                                    Capsule().stroke(Color.brinzaBlue, lineWidth: 1)
                                }
                            }
                            .buttonStyle(BrinzaPressStyle())
                        }
                    }
                }
                if visible.isEmpty {
                    BrinzaTicketCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "book")
                                .font(.largeTitle)
                                .foregroundStyle(Color.brinzaPink)
                            Text("Browse delicious meal ideas!")
                                .font(.headline)
                                .foregroundStyle(Color.brinzaInk)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Try another word or show every style.")
                                .font(.subheadline)
                                .foregroundStyle(Color.brinzaInk.opacity(0.75))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            BrinzaQuietButton(title: "Show all styles") {
                                query = ""
                                vault.brinzaSetCategory("All")
                            }
                        }
                    }
                } else {
                    ForEach(visible) { card in
                        NavigationLink(value: BrinzaRoute.recipe(card.id)) {
                            BrinzaTicketCard {
                                HStack(alignment: .top, spacing: 10) {
                                    BrinzaStillFrame(key: card.stillKey, height: 78)
                                        .frame(width: 108)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(card.title)
                                            .font(.headline)
                                            .foregroundStyle(Color.brinzaInk)
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text("\(card.styleTag) · \(card.minutes) min")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Color.brinzaPink)
                                        Text(vault.brinzaGapCount(card) == 0 ? "Ready to cook" : "\(vault.brinzaGapCount(card)) to buy")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(Color.brinzaBlue)
                                        if let taste = vault.brinzaTaste(for: card.id) {
                                            Text(BrinzaTasteCopy.line(taste))
                                                .font(.caption)
                                                .foregroundStyle(Color.brinzaPink)
                                                .lineLimit(nil)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        Text(card.blurb)
                                            .font(.caption)
                                            .foregroundStyle(Color.brinzaInk.opacity(0.78))
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                        if vault.favoriteRecipes.contains(card.id) {
                                            Text("Saved")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(Color.brinzaBlue)
                                        }
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(vault.favoriteRecipes.contains(card.id) ? "Remove saved" : "Save idea") {
                                vault.brinzaToggleFavorite(card.id)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

private struct BrinzaTonightCard: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @State private var cookToken: BrinzaCookToken?

    var body: some View {
        let today = BrinzaWeekName.todayIndex
        let planned = vault.daySlots.first { $0.weekdayIndex == today }.flatMap { BrinzaRecipeAtlas.brinzaFind($0.recipeID) }
        let suggestion = planned ?? vault.brinzaSuggestTonight()
        let streak = vault.brinzaStreakCount()
        BrinzaTicketCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Tonight · \(BrinzaWeekName.days[today])")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.brinzaPink)
                if streak > 0 {
                    Text(vault.brinzaCookedToday() ? "\(streak)-day streak is safe for today." : "\(streak)-day streak. Cook tonight to keep it.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.brinzaInk)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let recipe = suggestion {
                    if planned == nil {
                        Text("Nothing is on tonight yet.")
                            .font(.headline)
                            .foregroundStyle(Color.brinzaInk)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("A good next plate is \(recipe.title). \(vault.brinzaGapCount(recipe) == 0 ? "You already have the ingredients." : "\(vault.brinzaGapCount(recipe)) ingredients are still out.")")
                            .font(.subheadline)
                            .foregroundStyle(Color.brinzaInk.opacity(0.8))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        BrinzaPrimaryButton(title: "Plan it for tonight") {
                            vault.brinzaPlace(recipeID: recipe.id, weekday: today, portions: vault.defaultPortions)
                        }
                    } else {
                        Text(recipe.title)
                            .font(.headline)
                            .foregroundStyle(Color.brinzaInk)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(vault.brinzaCookedThisWeek(recipe.id) ? "Already cooked this week." : (vault.brinzaGapCount(recipe) == 0 ? "Ready to cook." : "\(vault.brinzaGapCount(recipe)) still to buy."))
                            .font(.subheadline)
                            .foregroundStyle(Color.brinzaInk.opacity(0.8))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        if let live = vault.brinzaLiveCook(recipe.id) {
                            Text(BrinzaClockText.face(live.remainingSeconds))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.brinzaPink)
                            BrinzaPrimaryButton(title: "Open cook timer") {
                                cookToken = BrinzaCookToken(id: live.id)
                            }
                        } else {
                            BrinzaPrimaryButton(title: "Start cook timer") {
                                cookToken = BrinzaCookToken(id: vault.brinzaStartCook(recipe))
                            }
                        }
                    }
                    NavigationLink(value: BrinzaRoute.recipe(recipe.id)) {
                        Text("Open idea")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.brinzaBlue)
                    }
                }
            }
        }
        .sheet(item: $cookToken) { token in
            BrinzaCookSession(tickID: token.id)
        }
    }
}

enum BrinzaIdeaBrowserKelvDrift {
    static func brinzaIdeaBrowserKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "qpyvkcxipjviwo-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 68) &+ Int(scalar.value)
        }
    }
}
