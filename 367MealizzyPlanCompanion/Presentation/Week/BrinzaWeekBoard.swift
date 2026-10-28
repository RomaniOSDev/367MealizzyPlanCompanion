import SwiftUI

struct BrinzaWeekBoard: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @State private var clearIndex: Int?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if vault.showHints {
                    BrinzaTicketCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Place ideas on the days you want to cook. Then build the pantry from the whole week.")
                                .font(.subheadline)
                                .foregroundStyle(Color.brinzaInk)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            BrinzaQuietButton(title: "Hide this hint") {
                                vault.brinzaDismissHints()
                            }
                        }
                    }
                }
                Text("\(vault.daySlots.count) planned · \(vault.brinzaWeekCookedCount()) cooked this week")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.brinzaInk)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                BrinzaPrimaryButton(title: "Build pantry from the week") {
                    vault.brinzaPourWeek()
                }
                BrinzaQuietButton(title: "Fill empty days") {
                    vault.brinzaFillEmptyDays()
                }
                if vault.daySlots.isEmpty {
                    BrinzaTicketCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.largeTitle)
                                .foregroundStyle(Color.brinzaBlue)
                            Text("No meals placed yet")
                                .font(.headline)
                                .foregroundStyle(Color.brinzaInk)
                                .lineLimit(nil)
                            Text("Open an idea and choose a weekday, or fill the empty days from plates you liked.")
                                .font(.subheadline)
                                .foregroundStyle(Color.brinzaInk.opacity(0.78))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                ForEach(BrinzaWeekName.days.indices, id: \.self) { index in
                    let slot = vault.daySlots.first { $0.weekdayIndex == index }
                    BrinzaTicketCard {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(BrinzaWeekName.days[index])
                                    .font(.headline)
                                    .foregroundStyle(Color.brinzaInk)
                                if index == BrinzaWeekName.todayIndex {
                                    Text("Today")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color.brinzaOnPrimary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(Color.brinzaPink))
                                }
                            }
                            if let slot, let recipe = BrinzaRecipeAtlas.brinzaFind(slot.recipeID) {
                                Text(recipe.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.brinzaPink)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("\(slot.portions) serving\(slot.portions == 1 ? "" : "s") · \(recipe.minutes) min")
                                    .font(.caption)
                                    .foregroundStyle(Color.brinzaInk.opacity(0.75))
                                    .lineLimit(nil)
                                if vault.brinzaCookedThisWeek(recipe.id) {
                                    Text("Cooked this week")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color.brinzaBlue)
                                }
                                NavigationLink(value: BrinzaRoute.recipe(recipe.id)) {
                                    Text("Open idea")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(Color.brinzaBlue)
                                }
                                BrinzaQuietButton(title: "Clear day") {
                                    clearIndex = index
                                }
                            } else {
                                Text("Empty day")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.brinzaInk.opacity(0.7))
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.immediately)
        .confirmationDialog("Clear this day?", isPresented: Binding(get: { clearIndex != nil }, set: { if $0 == false { clearIndex = nil } }), titleVisibility: .visible) {
            Button("Clear", role: .destructive) {
                if let clearIndex { vault.brinzaClearDay(clearIndex) }
                clearIndex = nil
            }
            Button("Cancel", role: .cancel) { clearIndex = nil }
        } message: {
            Text("The idea itself stays in the browser.")
        }
    }
}

enum BrinzaWeekBoardKelvDrift {
    static func brinzaWeekBoardKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "jjyrsdrztopxhh-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 64) &+ Int(scalar.value)
        }
    }
}
