import SwiftUI

struct ContentView: View {
    @StateObject private var brinzaVault = BrinzaLedgerVault()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if brinzaVault.hasSeenOnboarding {
                BrinzaRootShell()
            } else {
                BrinzaWelcomeReel()
            }
        }
        .environmentObject(brinzaVault)
        .environment(\.locale, Locale(identifier: "en_US"))
        .overlay(BrinzaKeypadVeil())
        .onChange(of: scenePhase) { phase in
            if phase != .active {
                brinzaVault.brinzaPauseForLeave()
            }
        }
    }
}

struct BrinzaRootShell: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @State private var lane: BrinzaLane = .ideas
    @State private var path = NavigationPath()
    @State private var pendingLane: BrinzaLane?

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                    HStack(alignment: .center, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lane.brinzaTitle)
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .foregroundStyle(Color.brinzaInk)
                                .lineLimit(nil)
                            Text(vault.brinzaReturnCaption())
                                .font(.caption)
                                .foregroundStyle(Color.brinzaInk.opacity(0.75))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 8)
                        NavigationLink(value: BrinzaRoute.setup) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.brinzaOnPrimary)
                                .frame(width: 48, height: 48)
                                .background(Circle().fill(LinearGradient(colors: [Color.brinzaPink, Color.brinzaBlue], startPoint: .top, endPoint: .bottom)))
                        }
                        .accessibilityLabel("Setup")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(BrinzaLane.allCases) { item in
                                Button {
                                    lane = item
                                } label: {
                                    Text(item.brinzaTitle)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(lane == item ? Color.brinzaOnPrimary : Color.brinzaInk)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background {
                                            if lane == item {
                                                Capsule().fill(LinearGradient(colors: [Color.brinzaPink, Color.brinzaBlue], startPoint: .leading, endPoint: .trailing))
                                            } else {
                                                Capsule().stroke(Color.brinzaPink, lineWidth: 1.2)
                                            }
                                        }
                                }
                                .buttonStyle(BrinzaPressStyle())
                                .accessibilityAddTraits(lane == item ? .isSelected : [])
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    if let banner = vault.brinzaBanner {
                        BrinzaBannerLine(text: banner)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 6)
                    }
                    Group {
                        switch lane {
                        case .ideas:
                            BrinzaIdeaBrowser()
                        case .week:
                            BrinzaWeekBoard()
                        case .pantry:
                            BrinzaPantryRoll()
                        case .timers:
                            BrinzaTickBoard()
                        case .log:
                            BrinzaCookLog()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                BrinzaBackdropFill(still: BrinzaStillRack.bowl, photoOpacity: 0.22)
            }
            .background(BrinzaHostPaint())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: BrinzaRoute.self) { route in
                switch route {
                case .recipe(let id):
                    BrinzaRecipeLeaf(recipeID: id)
                case .setup:
                    BrinzaPreferenceCanvas()
                }
            }
        }
        .tint(Color.brinzaPink)
        .onChange(of: vault.brinzaFocusLane) { focus in
            guard let focus else { return }
            vault.brinzaFocusLane = nil
            let next = focus
            DispatchQueue.main.async {
                if path.isEmpty {
                    lane = next
                } else {
                    pendingLane = next
                    path = NavigationPath()
                    DispatchQueue.main.async {
                        guard path.isEmpty, pendingLane == next else { return }
                        pendingLane = nil
                        lane = next
                    }
                }
            }
        }
        .onChange(of: path.count) { count in
            guard count == 0, let pendingLane else { return }
            self.pendingLane = nil
            lane = pendingLane
        }
    }
}

enum ContentViewKelvDrift {
    static func contentViewKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "ggbmlctyyojkqh-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 5) &+ Int(scalar.value)
        }
    }
}
