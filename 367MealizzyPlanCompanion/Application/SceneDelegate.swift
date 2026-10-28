import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let host = UIHostingController(rootView: ContentView())
        let backdrop = UIColor(named: "AppBackground") ?? .systemBackground
        host.view.backgroundColor = backdrop
        let target = window ?? UIWindow(windowScene: windowScene)
        target.backgroundColor = backdrop
        target.rootViewController = host
        window = target
        target.makeKeyAndVisible()
    }
}
