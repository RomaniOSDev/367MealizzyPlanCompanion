import SwiftUI

struct BrinzaRecipeLeaf: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    let recipeID: String
    @State private var portions: Int
    @State private var pickingDay = false
    @State private var cookToken: BrinzaCookToken?

    init(recipeID: String) {
        self.recipeID = recipeID
        _portions = State(initialValue: 1)
    }

    private var recipe: BrinzaRecipeCard? {
        BrinzaRecipeAtlas.brinzaFind(recipeID)
    }

    var body: some View {
        BrinzaScreen(still: recipe?.stillKey ?? BrinzaStillRack.bowl) {
            ScrollView {
                if let recipe {
                    VStack(alignment: .leading, spacing: 12) {
                        BrinzaStillFrame(key: recipe.stillKey, height: 160)
                        Text(recipe.title)
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundStyle(Color.brinzaInk)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(recipe.blurb)
                            .font(.body)
                            .foregroundStyle(Color.brinzaInk.opacity(0.82))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("\(recipe.styleTag) · about \(recipe.minutes) minutes · \(portions) serving\(portions == 1 ? "" : "s")")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.brinzaPink)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(vault.brinzaGapCount(recipe) == 0 ? "You can cook this with what is already in the kitchen." : "\(vault.brinzaGapCount(recipe)) ingredient\(vault.brinzaGapCount(recipe) == 1 ? "" : "s") still to buy.")
                            .font(.subheadline)
                            .foregroundStyle(Color.brinzaInk.opacity(0.8))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        if let taste = vault.brinzaTaste(for: recipe.id) {
                            Text(BrinzaTasteCopy.line(taste))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.brinzaBlue)
                        }
                        if let banner = vault.brinzaBanner {
                            BrinzaBannerLine(text: banner)
                        }
                        if let live = vault.brinzaLiveCook(recipe.id) {
                            BrinzaTicketCard {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(live.running ? "Cook timer is running" : "Cook timer is paused")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.brinzaInk)
                                    Text(BrinzaClockText.face(live.remainingSeconds))
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.brinzaPink)
                                }
                            }
                        }
                        Stepper(value: $portions, in: 1...4) {
                            Text("Servings \(portions)")
                                .foregroundStyle(Color.brinzaInk)
                        }
                        .onChange(of: portions) { value in
                            vault.brinzaSetPortions(value)
                        }
                        BrinzaQuietButton(title: vault.favoriteRecipes.contains(recipe.id) ? "Remove saved idea" : "Save this idea") {
                            vault.brinzaToggleFavorite(recipe.id)
                        }
                        Text("Ingredients")
                            .font(.headline)
                            .foregroundStyle(Color.brinzaInk)
                        ForEach(recipe.ingredients) { bit in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(bit.baseCount * portions) \(bit.unitLabel) \(bit.name)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.brinzaInk)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(bit.aisle)
                                    .font(.caption)
                                    .foregroundStyle(Color.brinzaBlue)
                                Text(vault.brinzaInKitchen(bit) ? "In the kitchen" : (vault.brinzaOnShoppingList(bit) ? "Already on the pantry list" : "Still to buy"))
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color.brinzaPink)
                                Button(vault.ingredientOwnership[bit.id] == true ? "In the kitchen" : "Mark in the kitchen") {
                                    vault.brinzaToggleOwned(bit.id)
                                }
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.brinzaPink)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(BrinzaTicketShape().fill(Color.brinzaCard))
                        }
                        Text("Steps")
                            .font(.headline)
                            .foregroundStyle(Color.brinzaInk)
                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            Text("\(index + 1). \(step)")
                                .font(.body)
                                .foregroundStyle(Color.brinzaInk)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        BrinzaTasteRow(recipeID: recipe.id)
                        BrinzaPrimaryButton(title: "Add missing ingredients") {
                            vault.brinzaSendRecipe(recipe, portions: portions)
                        }
                        BrinzaPrimaryButton(title: "Place on a weekday") {
                            pickingDay = true
                        }
                        BrinzaPrimaryButton(title: vault.brinzaLiveCook(recipe.id) == nil ? "Start cook timer" : "Open cook timer") {
                            cookToken = BrinzaCookToken(id: vault.brinzaStartCook(recipe))
                        }
                    }
                    .padding(16)
                } else {
                    Text("This idea is unavailable.")
                        .padding(16)
                        .foregroundStyle(Color.brinzaInk)
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .navigationTitle("Idea")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(Color.brinzaBackdrop, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            portions = vault.defaultPortions
        }
        .sheet(isPresented: $pickingDay) {
            BrinzaDayPicker(recipeID: recipeID, portions: portions)
        }
        .sheet(item: $cookToken) { token in
            BrinzaCookSession(tickID: token.id)
        }
    }
}

struct BrinzaDayPicker: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @Environment(\.dismiss) private var dismiss
    let recipeID: String
    let portions: Int

    var body: some View {
        NavigationStack {
            BrinzaScreen(still: BrinzaStillRack.board) {
                ScrollView {
                    VStack(spacing: 10) {
                        Text("Choose the day for \(portions) serving\(portions == 1 ? "" : "s").")
                            .font(.subheadline)
                            .foregroundStyle(Color.brinzaInk)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        ForEach(BrinzaWeekName.days.indices, id: \.self) { index in
                            Button(index == BrinzaWeekName.todayIndex ? "\(BrinzaWeekName.days[index]) · today" : BrinzaWeekName.days[index]) {
                                vault.brinzaPlace(recipeID: recipeID, weekday: index, portions: portions)
                                dismiss()
                            }
                            .font(.headline)
                            .foregroundStyle(Color.brinzaOnPrimary)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(BrinzaTicketShape().fill(index == BrinzaWeekName.todayIndex ? Color.brinzaPink : Color.brinzaBlue))
                            .buttonStyle(BrinzaPressStyle())
                        }
                        BrinzaQuietButton(title: "Cancel") { dismiss() }
                    }
                    .padding(16)
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle("Weekday")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brinzaBackdrop, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct BrinzaCookSession: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @Environment(\.dismiss) private var dismiss
    let tickID: UUID

    private var tick: BrinzaCookTick? {
        vault.cookTicks.first { $0.id == tickID }
    }

    private var recipe: BrinzaRecipeCard? {
        guard let recipeID = vault.tickRecipe[tickID.uuidString] else { return nil }
        return BrinzaRecipeAtlas.brinzaFind(recipeID)
    }

    var body: some View {
        NavigationStack {
            BrinzaScreen(still: recipe?.stillKey ?? BrinzaStillRack.noodles) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if let tick {
                            Text(tick.dishName)
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .foregroundStyle(Color.brinzaInk)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(BrinzaClockText.face(tick.remainingSeconds))
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.brinzaPink)
                                .lineLimit(1)
                            if tick.finished {
                                Text("Ready. Tell the log how it went so next week can use it.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.brinzaInk.opacity(0.82))
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            } else if tick.running {
                                Text("Counting down. Leave the app and it pauses.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.brinzaBlue)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            } else if tick.pausedByLeave {
                                Text("Paused while you were away. Resume when you are back at the stove.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.brinzaInk.opacity(0.82))
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            } else {
                                Text("Paused.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.brinzaInk.opacity(0.82))
                            }
                            if tick.finished == false {
                                if tick.running {
                                    BrinzaQuietButton(title: "Pause") { vault.brinzaSetRunning(tick.id, running: false) }
                                } else {
                                    BrinzaPrimaryButton(title: "Resume") { vault.brinzaSetRunning(tick.id, running: true) }
                                }
                            }
                            if let recipe {
                                Text("Steps")
                                    .font(.headline)
                                    .foregroundStyle(Color.brinzaInk)
                                let current = min(vault.brinzaStep(for: tick.id), max(0, recipe.steps.count - 1))
                                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                                    Button {
                                        vault.brinzaSetStep(tick.id, index)
                                    } label: {
                                        HStack(alignment: .top, spacing: 8) {
                                            Text(index < current ? "Done" : (index == current ? "Now" : "\(index + 1)"))
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(index == current ? Color.brinzaOnPrimary : Color.brinzaPink)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background {
                                                    Capsule().fill(index == current ? Color.brinzaPink : Color.clear)
                                                }
                                            Text(step)
                                                .font(.body)
                                                .foregroundStyle(Color.brinzaInk)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(nil)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer(minLength: 0)
                                        }
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(BrinzaTicketShape().fill(Color.brinzaCard))
                                    }
                                    .buttonStyle(BrinzaPressStyle())
                                }
                            if tick.finished == false, current < recipe.steps.count - 1 {
                                BrinzaQuietButton(title: "Next step") {
                                    vault.brinzaSetStep(tick.id, current + 1)
                                }
                            }
                            }
                            if tick.finished, let recipe {
                                Text("How was it?")
                                    .font(.headline)
                                    .foregroundStyle(Color.brinzaInk)
                                BrinzaTasteRow(recipeID: recipe.id)
                            } else if tick.finished == false {
                                BrinzaPrimaryButton(title: "Mark ready") { vault.brinzaMarkReady(tick.id) }
                            }
                            BrinzaQuietButton(title: "Close") { dismiss() }
                        } else {
                            Text("This timer is no longer on the board.")
                                .foregroundStyle(Color.brinzaInk)
                            BrinzaQuietButton(title: "Close") { dismiss() }
                        }
                    }
                    .padding(16)
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle("Cook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brinzaBackdrop, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct BrinzaTasteRow: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    let recipeID: String

    private let choices: [(String, String)] = [
        ("Again", BrinzaTaste.again),
        ("Fine", BrinzaTaste.fine),
        ("Skip", BrinzaTaste.skip)
    ]

    var body: some View {
        let current = vault.brinzaTaste(for: recipeID)
        HStack(spacing: 8) {
            ForEach(choices, id: \.1) { title, reaction in
                Button(title) {
                    vault.brinzaSetTaste(recipeID: recipeID, reaction: reaction)
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(current == reaction ? Color.brinzaOnPrimary : Color.brinzaInk)
                .frame(maxWidth: .infinity, minHeight: 36)
                .background {
                    if current == reaction {
                        Capsule().fill(Color.brinzaPink)
                    } else {
                        Capsule().stroke(Color.brinzaPink, lineWidth: 1.2)
                    }
                }
                .buttonStyle(BrinzaPressStyle())
            }
        }
    }
}

enum BrinzaTasteCopy {
    static func line(_ reaction: String) -> String {
        switch reaction {
        case BrinzaTaste.again: return "You would make this again."
        case BrinzaTaste.skip: return "You would skip this next time."
        default: return "You marked this one as fine."
        }
    }
}

enum BrinzaRecipeLeafKelvDrift {
    static func brinzaRecipeLeafKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "ulkqeajjrchygi-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 12) &+ Int(scalar.value)
        }
    }
}
