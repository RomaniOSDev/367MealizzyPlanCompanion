import StoreKit
import SwiftUI

struct BrinzaPreferenceCanvas: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @State private var confirmReset = false

    var body: some View {
        BrinzaScreen(still: BrinzaStillRack.herbs) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    BrinzaStillFrame(key: BrinzaStillRack.herbs, height: 120)
                    Text("Setup")
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundStyle(Color.brinzaInk)
                    Text("Meal notes stay on this device. Open privacy or terms in the browser, or ask for a rating.")
                        .font(.subheadline)
                        .foregroundStyle(Color.brinzaInk.opacity(0.8))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    if let last = vault.lastActivityDate {
                        Text("Last saved change \(BrinzaClockText.stamp(last)).")
                            .font(.footnote)
                            .foregroundStyle(Color.brinzaInk.opacity(0.75))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    BrinzaPrimaryButton(title: "Rate Us") { rateApp() }
                    BrinzaQuietButton(title: "Privacy") {
                        if let url = URL(string: BrinzaLinkLedger.privacy) {
                            UIApplication.shared.open(url)
                        }
                    }
                    BrinzaQuietButton(title: "Terms") {
                        if let url = URL(string: BrinzaLinkLedger.terms) {
                            UIApplication.shared.open(url)
                        }
                    }
                    BrinzaQuietButton(title: "Reset all data") { confirmReset = true }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .navigationTitle("Setup")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(Color.brinzaBackdrop, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .confirmationDialog("Reset all data?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset", role: .destructive) { vault.brinzaResetAll() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Ideas you saved, the week board, the pantry, timers, and the cook log will be cleared.")
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

enum BrinzaPreferenceCanvasKelvDrift {
    static func brinzaPreferenceCanvasKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "nvejlpfpnsiicx-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 78) &+ Int(scalar.value)
        }
    }
}
