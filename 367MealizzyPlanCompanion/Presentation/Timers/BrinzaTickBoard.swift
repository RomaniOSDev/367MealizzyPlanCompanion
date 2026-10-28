import SwiftUI

struct BrinzaTickBoard: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @State private var making = false
    @State private var editing: BrinzaCookTick?
    @State private var pendingDiscard: BrinzaCookTick?

    private var active: [BrinzaCookTick] { vault.cookTicks.filter { $0.finished == false } }
    private var done: [BrinzaCookTick] { vault.cookTicks.filter(\.finished) }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                BrinzaPrimaryButton(title: "Add a timer") { making = true }
                if vault.cookTicks.isEmpty {
                    BrinzaTicketCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "stopwatch")
                                .font(.largeTitle)
                                .foregroundStyle(Color.brinzaPink)
                            Text("Start cooking by adding your first timer")
                                .font(.headline)
                                .foregroundStyle(Color.brinzaInk)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Name the dish and enter the minutes. Timers pause if you leave the app.")
                                .font(.subheadline)
                                .foregroundStyle(Color.brinzaInk.opacity(0.78))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                if active.isEmpty == false {
                    Text("Running and paused")
                        .font(.headline)
                        .foregroundStyle(Color.brinzaInk)
                    ForEach(active) { tick in
                        BrinzaTickCard(tick: tick, editing: $editing, pendingDiscard: $pendingDiscard)
                    }
                }
                if done.isEmpty == false {
                    Text("Completed")
                        .font(.headline)
                        .foregroundStyle(Color.brinzaInk)
                    ForEach(done) { tick in
                        BrinzaTickCard(tick: tick, editing: $editing, pendingDiscard: $pendingDiscard)
                    }
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.immediately)
        .sheet(isPresented: $making) {
            BrinzaTickEditor(existing: nil)
        }
        .sheet(item: $editing) { tick in
            BrinzaTickEditor(existing: tick)
        }
        .confirmationDialog("Discard this timer?", isPresented: Binding(get: { pendingDiscard != nil }, set: { if $0 == false { pendingDiscard = nil } }), titleVisibility: .visible) {
            Button("Discard", role: .destructive) {
                if let pendingDiscard { vault.brinzaDiscardTick(pendingDiscard.id) }
                pendingDiscard = nil
            }
            Button("Cancel", role: .cancel) { pendingDiscard = nil }
        } message: {
            Text("It will not be written to the cook log.")
        }
    }
}

private struct BrinzaTickCard: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    let tick: BrinzaCookTick
    @Binding var editing: BrinzaCookTick?
    @Binding var pendingDiscard: BrinzaCookTick?

    var body: some View {
        BrinzaTicketCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(tick.dishName)
                    .font(.headline)
                    .foregroundStyle(Color.brinzaInk)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Text(BrinzaClockText.face(tick.remainingSeconds))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.brinzaPink)
                    .lineLimit(nil)
                if tick.finished {
                    Text("Ready")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.brinzaBlue)
                } else if tick.pausedByLeave {
                    Text("Paused while you were away.")
                        .font(.footnote)
                        .foregroundStyle(Color.brinzaInk.opacity(0.8))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                } else if tick.running {
                    Text("Counting down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.brinzaBlue)
                } else {
                    Text("Paused")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.brinzaInk.opacity(0.75))
                }
                if tick.finished == false {
                    if tick.running {
                        BrinzaQuietButton(title: "Pause") { vault.brinzaSetRunning(tick.id, running: false) }
                    } else {
                        BrinzaPrimaryButton(title: "Resume") { vault.brinzaSetRunning(tick.id, running: true) }
                    }
                    BrinzaQuietButton(title: "Mark ready") { vault.brinzaMarkReady(tick.id) }
                }
                BrinzaQuietButton(title: "Edit") { editing = tick }
                BrinzaQuietButton(title: "Discard") { pendingDiscard = tick }
            }
        }
        .contextMenu {
            Button("Edit") { editing = tick }
            Button("Discard", role: .destructive) { pendingDiscard = tick }
        }
    }
}

struct BrinzaTickEditor: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @Environment(\.dismiss) private var dismiss
    let existing: BrinzaCookTick?
    @State private var name: String
    @State private var minutesText: String
    @State private var trouble: String?

    init(existing: BrinzaCookTick?) {
        self.existing = existing
        _name = State(initialValue: existing?.dishName ?? "")
        let minutes = max(1, (existing?.durationSeconds ?? 60) / 60)
        _minutesText = State(initialValue: existing == nil ? "" : "\(minutes)")
    }

    var body: some View {
        NavigationStack {
            BrinzaScreen(still: BrinzaStillRack.noodles) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dish name")
                        .font(.subheadline.weight(.semibold))
                    TextField("Name the dish", text: $name)
                        .padding(12)
                        .foregroundStyle(Color.brinzaInk)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.brinzaCard))
                    Text("Minutes")
                        .font(.subheadline.weight(.semibold))
                    TextField("Whole minutes from 1 to 240", text: $minutesText)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .foregroundStyle(Color.brinzaInk)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.brinzaCard))
                    Text("Saving replaces the remaining time with the minutes you enter.")
                        .font(.footnote)
                        .foregroundStyle(Color.brinzaInk.opacity(0.75))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    if let trouble {
                        Text(trouble)
                            .foregroundStyle(Color.brinzaInk)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    BrinzaPrimaryButton(title: "Save timer") { commit() }
                    BrinzaQuietButton(title: "Cancel") { dismiss() }
                }
                .foregroundStyle(Color.brinzaInk)
                .padding(16)
            }
            .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle("Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brinzaBackdrop, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func commit() {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.isEmpty {
            trouble = "Add a dish name before saving."
            return
        }
        guard let minutes = Int(minutesText.trimmingCharacters(in: .whitespacesAndNewlines)), minutes >= 1, minutes <= 240 else {
            trouble = "Enter a whole number of minutes from 1 to 240."
            return
        }
        let seconds = minutes * 60
        if let existing {
            var next = existing
            next.dishName = clean
            next.durationSeconds = seconds
            next.remainingSeconds = seconds
            next.finished = false
            next.running = false
            next.pausedByLeave = false
            vault.brinzaSaveTick(next)
        } else {
            vault.brinzaStartTimer(name: clean, minutes: minutes)
        }
        dismiss()
    }
}

enum BrinzaTickBoardKelvDrift {
    static func brinzaTickBoardKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "ocprvubbrvzpbw-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 5) &+ Int(scalar.value)
        }
    }
}
