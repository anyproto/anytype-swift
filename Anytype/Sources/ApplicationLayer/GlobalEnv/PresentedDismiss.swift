import Foundation
import SwiftUI

struct DismissAllPresented {
    
    private weak var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func callAsFunction(animated: Bool = true) async {
        await withCheckedContinuation { continuation in
            Task { @MainActor [weak window] in
                if let root = window?.rootViewController {
                    root.dismiss(animated: animated, completion: {
                        continuation.resume()
                    })
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

struct PresentedDismissKey: EnvironmentKey {
    static let defaultValue = DismissAllPresented(window: nil)
}

extension EnvironmentValues {
    var dismissAllPresented: DismissAllPresented {
        get { self[PresentedDismissKey.self] }
        set { self[PresentedDismissKey.self] = newValue }
    }
}

extension View {
    func setPresentedDismissEnv(window: UIWindow?) -> some View {
        environment(\.dismissAllPresented, DismissAllPresented(window: window))
    }
}
