import SwiftUI

struct BrinzaPantryRoll: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @State private var editor: BrinzaPantryBit?
    @State private var makingNew = false
    @State private var pendingDelete: BrinzaPantryBit?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                BrinzaPrimaryButton(title: "Add an item") { makingNew = true }
                if vault.pantry.isEmpty {
                    BrinzaTicketCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "leaf.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color.brinzaPink)
                            Text("Add your first pantry item")
                                .font(.headline)
                                .foregroundStyle(Color.brinzaInk)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("You can also send ingredients from a meal idea.")
                                .font(.subheadline)
                                .foregroundStyle(Color.brinzaInk.opacity(0.78))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                ForEach(BrinzaAisleRack.order, id: \.self) { aisle in
                    let rows = vault.pantry.filter { $0.aisle == aisle && $0.packed == false }
                    if rows.isEmpty == false {
                        Text(aisle)
                            .font(.headline)
                            .foregroundStyle(Color.brinzaInk)
                        ForEach(rows) { bit in
                            BrinzaPantryRow(bit: bit, editor: $editor, pendingDelete: $pendingDelete)
                        }
                    }
                }
                let gathered = vault.pantry.filter(\.packed)
                if gathered.isEmpty == false {
                    Text("Gathered")
                        .font(.headline)
                        .foregroundStyle(Color.brinzaInk)
                    ForEach(gathered) { bit in
                        BrinzaPantryRow(bit: bit, editor: $editor, pendingDelete: $pendingDelete)
                    }
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.immediately)
        .sheet(isPresented: $makingNew) {
            BrinzaPantryEditor(existing: nil)
        }
        .sheet(item: $editor) { bit in
            BrinzaPantryEditor(existing: bit)
        }
        .confirmationDialog("Remove this item?", isPresented: Binding(get: { pendingDelete != nil }, set: { if $0 == false { pendingDelete = nil } }), titleVisibility: .visible) {
            Button("Remove", role: .destructive) {
                if let pendingDelete { vault.brinzaDeletePantry(pendingDelete.id) }
                pendingDelete = nil
            }
            Button("Cancel", role: .cancel) { pendingDelete = nil }
        } message: {
            Text("It leaves the pantry list only.")
        }
    }
}

private struct BrinzaPantryRow: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    let bit: BrinzaPantryBit
    @Binding var editor: BrinzaPantryBit?
    @Binding var pendingDelete: BrinzaPantryBit?

    var body: some View {
        BrinzaTicketCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(bit.name)
                    .font(.headline)
                    .foregroundStyle(Color.brinzaInk)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(bit.count) \(bit.unitLabel) · \(bit.aisle)")
                    .font(.subheadline)
                    .foregroundStyle(Color.brinzaInk.opacity(0.8))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                if bit.fromDish.isEmpty == false {
                    Text("From \(bit.fromDish)")
                        .font(.caption)
                        .foregroundStyle(Color.brinzaPink)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button(bit.packed ? "Return to list" : "Mark gathered") {
                    vault.brinzaTogglePacked(bit.id)
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.brinzaBlue)
                HStack {
                    Button("Edit") { editor = bit }
                    Button("Delete") { pendingDelete = bit }
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.brinzaPink)
            }
        }
    }
}

struct BrinzaPantryEditor: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @Environment(\.dismiss) private var dismiss
    let existing: BrinzaPantryBit?
    @State private var name: String
    @State private var aisle: String
    @State private var unitLabel: String
    @State private var count: Int
    @State private var trouble: String?

    init(existing: BrinzaPantryBit?) {
        self.existing = existing
        _name = State(initialValue: existing?.name ?? "")
        _aisle = State(initialValue: existing?.aisle ?? "Produce")
        _unitLabel = State(initialValue: existing?.unitLabel ?? "piece")
        _count = State(initialValue: max(1, existing?.count ?? 1))
    }

    var body: some View {
        NavigationStack {
            BrinzaScreen(still: BrinzaStillRack.herbs) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Name")
                        .font(.subheadline.weight(.semibold))
                    TextField("Item name", text: $name)
                        .padding(12)
                        .foregroundStyle(Color.brinzaInk)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.brinzaCard))
                    Text("Unit")
                        .font(.subheadline.weight(.semibold))
                    TextField("piece, cup, handful", text: $unitLabel)
                        .padding(12)
                        .foregroundStyle(Color.brinzaInk)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.brinzaCard))
                    Text("Aisle")
                        .font(.subheadline.weight(.semibold))
                    ForEach(BrinzaAisleRack.order, id: \.self) { item in
                        Button(item) { aisle = item }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(aisle == item ? Color.brinzaOnPrimary : Color.brinzaInk)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background {
                                if aisle == item {
                                    Capsule().fill(Color.brinzaBlue)
                                } else {
                                    Capsule().stroke(Color.brinzaBlue, lineWidth: 1)
                                }
                            }
                    }
                    Stepper(value: $count, in: 1...99) {
                        Text("Count \(count)")
                    }
                    if let trouble {
                        Text(trouble)
                            .font(.footnote)
                            .foregroundStyle(Color.brinzaInk)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    BrinzaPrimaryButton(title: "Save item") { commit() }
                    BrinzaQuietButton(title: "Cancel") { dismiss() }
                }
                .foregroundStyle(Color.brinzaInk)
                .padding(16)
            }
            .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle("Pantry item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brinzaBackdrop, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func commit() {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let unit = unitLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.isEmpty {
            trouble = "Add a name before saving."
            return
        }
        if unit.isEmpty {
            trouble = "Add a unit such as cup or piece."
            return
        }
        if count < 1 {
            trouble = "Count has to be at least 1."
            return
        }
        vault.brinzaSavePantry(BrinzaPantryBit(
            id: existing?.id ?? UUID(),
            name: clean,
            aisle: aisle,
            unitLabel: unit,
            count: count,
            packed: existing?.packed ?? false,
            fromDish: existing?.fromDish ?? ""
        ), isNew: existing == nil)
        dismiss()
    }
}

enum BrinzaPantryRollKelvDrift {
    static func brinzaPantryRollKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "fmssqijhghhkso-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 65) &+ Int(scalar.value)
        }
    }
}
