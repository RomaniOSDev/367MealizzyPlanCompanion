import SwiftUI

struct BrinzaWelcomeReel: View {
    @EnvironmentObject private var vault: BrinzaLedgerVault
    @State private var page = 0

    private let pages: [(still: String, headline: String, detail: String)] = [
        (BrinzaStillRack.bowl, "Plan Your Meals", "Look through single-serving ideas and place one on a day of the week."),
        (BrinzaStillRack.herbs, "Build a Pantry List", "Send the ingredients you still need into a pantry list grouped by aisle."),
        (BrinzaStillRack.noodles, "Start Planning", "Open an idea, set the servings, then start a cook timer when you are ready.")
    ]

    var body: some View {
        BrinzaScreen(still: BrinzaStillRack.board) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Kitchen walkthrough")
                        .font(.system(.title2, design: .rounded).weight(.heavy))
                        .foregroundStyle(Color.brinzaInk)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Open a plate to read it. Every plate stays on the counter.")
                        .font(.subheadline)
                        .foregroundStyle(Color.brinzaInk.opacity(0.78))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(pages.indices, id: \.self) { index in
                        Button {
                            page = index
                        } label: {
                            if page == index {
                                HStack(alignment: .top, spacing: 10) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Plate \(index + 1)")
                                            .font(.caption.weight(.heavy))
                                            .foregroundStyle(Color.brinzaPink)
                                        Text(pages[index].headline)
                                            .font(.system(.title3, design: .rounded).weight(.bold))
                                            .foregroundStyle(Color.brinzaInk)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text(pages[index].detail)
                                            .font(.subheadline)
                                            .foregroundStyle(Color.brinzaInk.opacity(0.84))
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    brinzaThumb(pages[index].still)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    BrinzaTicketShape()
                                        .fill(Color.brinzaCard)
                                        .shadow(color: Color.brinzaPink.opacity(0.22), radius: 8, y: 4)
                                )
                                .overlay(
                                    BrinzaTicketShape().stroke(
                                        LinearGradient(colors: [Color.brinzaPink, Color.brinzaBlue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: 2
                                    )
                                )
                            } else {
                                HStack(spacing: 10) {
                                    Text("\(index + 1)")
                                        .font(.headline.weight(.heavy))
                                        .foregroundStyle(Color.brinzaOnPrimary)
                                        .frame(width: 36, height: 36)
                                        .background(Circle().fill(Color.brinzaBlue))
                                    Text(pages[index].headline)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(Color.brinzaInk)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 4)
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(Color.brinzaPink)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                                .background(BrinzaTicketShape().fill(Color.brinzaCard))
                            }
                        }
                        .buttonStyle(BrinzaPressStyle())
                        .accessibilityLabel(pages[index].headline)
                        .accessibilityAddTraits(page == index ? .isSelected : [])
                    }

                    HStack(spacing: 10) {
                        Button {
                            vault.brinzaMarkWelcomeDone()
                        } label: {
                            Text("Skip")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.brinzaPink)
                                .lineLimit(nil)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(BrinzaTicketShape().stroke(Color.brinzaPink, lineWidth: 1.5))
                        }
                        .buttonStyle(BrinzaPressStyle())

                        Button {
                            if page == pages.count - 1 {
                                vault.brinzaMarkWelcomeDone()
                            } else {
                                page += 1
                            }
                        } label: {
                            Text(page == pages.count - 1 ? "Start the week" : "Next plate")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.brinzaOnPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .padding(.horizontal, 8)
                                .background(
                                    BrinzaTicketShape().fill(
                                        LinearGradient(colors: [Color.brinzaPink, Color.brinzaBlue], startPoint: .leading, endPoint: .trailing)
                                    )
                                )
                        }
                        .buttonStyle(BrinzaPressStyle())
                    }
                    .padding(.top, 6)
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }

    private func brinzaThumb(_ key: String) -> some View {
        Color.clear
            .frame(width: 92, height: 78)
            .overlay {
                Image(key)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.brinzaBlue.opacity(0.45), lineWidth: 1))
            .accessibilityHidden(true)
    }
}

enum BrinzaWelcomeReelKelvDrift {
    static func brinzaWelcomeReelKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "ezksqxvuanjjoh-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 54) &+ Int(scalar.value)
        }
    }
}
