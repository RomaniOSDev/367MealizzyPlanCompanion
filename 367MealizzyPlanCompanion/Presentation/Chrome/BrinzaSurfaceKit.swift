import SwiftUI

extension Color {
    static let brinzaBackdrop = Color("AppBackground")
    static let brinzaCard = Color("AppSurface")
    static let brinzaPink = Color("AppPrimary")
    static let brinzaBlue = Color("AppAccent")
    static let brinzaInk = Color("AppInk")
    static let brinzaOnPrimary = Color("AppOnPrimary")
}

struct BrinzaPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
    }
}

struct BrinzaTicketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 22
        path.move(to: CGPoint(x: rect.minX + 8, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + radius), control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 8))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - 8, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - radius), control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 8))
        path.addQuadCurve(to: CGPoint(x: rect.minX + 8, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct BrinzaBackdropFill: View {
    var still: String = BrinzaStillRack.bowl
    var photoOpacity: Double = 0.28

    var body: some View {
        Color.brinzaBackdrop
            .overlay {
                Image(still)
                    .resizable()
                    .scaledToFill()
                    .opacity(photoOpacity)
            }
            .overlay {
                LinearGradient(
                    colors: [Color.brinzaBlue.opacity(0.18), Color.brinzaBackdrop.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipped()
            .ignoresSafeArea()
    }
}

struct BrinzaScreen<Content: View>: View {
    let still: String
    private let content: Content

    init(still: String, @ViewBuilder content: () -> Content) {
        self.still = still
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                BrinzaBackdropFill(still: still)
            }
            .background(BrinzaHostPaint())
    }
}

struct BrinzaHostPaint: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            let color = UIColor(named: "AppBackground")
            var responder: UIResponder? = uiView
            while let current = responder {
                if let controller = current as? UIViewController {
                    controller.view.backgroundColor = color
                    controller.navigationController?.view.backgroundColor = color
                    break
                }
                responder = current.next
            }
        }
    }
}

struct BrinzaStillFrame: View {
    let key: String
    var height: CGFloat = 140

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay {
                Image(key)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .clipShape(BrinzaTicketShape())
            .shadow(color: Color.brinzaBlue.opacity(0.25), radius: 8, y: 4)
    }
}

struct BrinzaTicketCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                BrinzaTicketShape()
                    .fill(Color.brinzaCard)
                    .shadow(color: Color.black.opacity(0.14), radius: 8, y: 5)
            )
            .overlay(
                BrinzaTicketShape()
                    .stroke(
                        LinearGradient(colors: [Color.brinzaPink, Color.brinzaBlue], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.5
                    )
            )
    }
}

struct BrinzaPrimaryButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.brinzaOnPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 12)
                .background(
                    BrinzaTicketShape()
                        .fill(LinearGradient(colors: [Color.brinzaPink, Color.brinzaBlue], startPoint: .leading, endPoint: .trailing))
                        .shadow(color: Color.brinzaPink.opacity(0.28), radius: 8, y: 4)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(BrinzaPressStyle())
    }
}

struct BrinzaQuietButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.brinzaPink)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 10)
                .background(BrinzaTicketShape().stroke(Color.brinzaPink, lineWidth: 1.5))
                .contentShape(Rectangle())
        }
        .buttonStyle(BrinzaPressStyle())
    }
}

struct BrinzaBannerLine: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.brinzaOnPrimary)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                BrinzaTicketShape().fill(LinearGradient(colors: [Color.brinzaPink, Color.brinzaBlue], startPoint: .leading, endPoint: .trailing))
            )
    }
}

struct BrinzaKeypadVeil: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let veil = UIView(frame: .zero)
        veil.isUserInteractionEnabled = false
        veil.backgroundColor = .clear
        return veil
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            guard context.coordinator.attached == false, let window = uiView.window else { return }
            let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.brinzaFoldKeys))
            tap.cancelsTouchesInView = false
            tap.delegate = context.coordinator
            tap.name = "brinzaFoldKeys"
            window.addGestureRecognizer(tap)
            context.coordinator.attached = true
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var attached = false

        @objc func brinzaFoldKeys() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            var node: UIView? = touch.view
            while let current = node {
                if current is UITextField || current is UITextView { return false }
                node = current.superview
            }
            return true
        }
    }
}

enum BrinzaSurfaceKitKelvDrift {
    static func brinzaSurfaceKitKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "ioueqhzlyicltl-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 67) &+ Int(scalar.value)
        }
    }
}
