import SwiftUI

struct BrinzaCookLog: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @State private var cookToken: BrinzaCookToken?

    var body: some View {
        let streak = vault.brinzaStreakCount()
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                Text("Finished dishes land here when a timer ends or you mark one ready.")
                    .font(.subheadline)
                    .foregroundStyle(Color.brinzaInk.opacity(0.82))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(vault.cookLog.count) finished")
                    .font(.headline)
                    .foregroundStyle(Color.brinzaPink)
                Text(streak == 0 ? "Finish a plate today to start a streak." : "\(streak)-day streak\(vault.brinzaCookedToday() ? ". Today is already in." : ". Cook today to keep it.")")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.brinzaInk)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                if vault.cookLog.isEmpty {
                    BrinzaTicketCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .font(.largeTitle)
                                .foregroundStyle(Color.brinzaBlue)
                            Text("No finished dishes yet")
                                .font(.headline)
                                .foregroundStyle(Color.brinzaInk)
                                .lineLimit(nil)
                            Text("Start a timer from an idea or from the timer board.")
                                .font(.subheadline)
                                .foregroundStyle(Color.brinzaInk.opacity(0.78))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } else {
                    ForEach(vault.cookLog) { memory in
                        BrinzaTicketCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(memory.dishName)
                                    .font(.headline)
                                    .foregroundStyle(Color.brinzaInk)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(BrinzaClockText.stamp(memory.finishedOn))
                                    .font(.subheadline)
                                    .foregroundStyle(Color.brinzaInk.opacity(0.78))
                                    .lineLimit(nil)
                                Text("Planned \(BrinzaClockText.face(memory.plannedSeconds))")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.brinzaBlue)
                                if let recipeID = vault.brinzaRecipeID(for: memory), let recipe = BrinzaRecipeAtlas.brinzaFind(recipeID) {
                                    BrinzaTasteRow(recipeID: recipeID)
                                    BrinzaPrimaryButton(title: vault.brinzaLiveCook(recipeID) == nil ? "Cook again" : "Open cook timer") {
                                        cookToken = BrinzaCookToken(id: vault.brinzaStartCook(recipe))
                                    }
                                }
                                BrinzaQuietButton(title: "Remove from log") {
                                    vault.brinzaDeleteMemory(memory.id)
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.immediately)
        .sheet(item: $cookToken) { token in
            BrinzaCookSession(tickID: token.id)
        }
    }
}

enum BrinzaCookLogKelvDrift {
    static func brinzaCookLogKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "rfcpklgyyjeshl-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 8) &+ Int(scalar.value)
        }
    }
}
