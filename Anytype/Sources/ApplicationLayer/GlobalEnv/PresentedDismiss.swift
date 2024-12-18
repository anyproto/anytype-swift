import Foundation
import SwiftUI

struct DismissAllPresented: Equatable {
    
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

extension EnvironmentValues {
    @Entry var dismissAllPresented = DismissAllPresented(window: nil)
}

extension View {
    func setPresentedDismissEnv(window: UIWindow?) -> some View {
        environment(\.dismissAllPresented, DismissAllPresented(window: window))
    }
}
