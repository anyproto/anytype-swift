import SwiftUI
import AnytypeCore

final class MainWindow: UIWindow {
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if let event = event, event.type == .motion, event.subtype == .motionShake {
            showFeatureFlags()
        }
    }
    
    private func showFeatureFlags() {
        #if DEBUG
            let flagsController = UIHostingController(rootView: FeatureFlagsView())
            self.rootViewController?.topPresentedController.present(flagsController, animated: true)
        #endif
    }
    
}
