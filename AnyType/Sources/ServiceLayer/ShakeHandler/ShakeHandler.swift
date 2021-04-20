import Foundation
import UIKit
import SwiftUI
import Combine
import os

final class ShakeHandler {
    var window: UIWindow?
    
    private var shakeSubscription: AnyCancellable?
    
    init(_ window: UIWindow?) {
        self.window = window
    }
    
    func run() {
        self.shakeSubscription = NotificationCenter.default.publisher(for: .DeviceDidShaked).sink { [weak self] (value) in
            self?.handle()
        }
    }

    // MARK: Shake Handler / Helpers
    private func isPresented<T>(asTopMost topMostPresented: UIViewController, of type: T.Type) -> Bool where T: UIViewController {
        if let container = topMostPresented as? UINavigationController {
            guard let first = container.viewControllers.first else {
                return false
            }
            return first is T
        }
        return topMostPresented is T
    }
    func topPresentedController(for controller: UIViewController) -> UIViewController? {
        return sequence(first: controller, next: (\.presentedViewController)).compactMap{$0}.last
    }

    // MARK: Shake Handler / Handle Action
    private func handle() {
        guard let rootViewController = self.window?.rootViewController else {
            return
        }
        
        guard let topMostController = self.topPresentedController(for: rootViewController) else {
            return
        }
        
        guard !self.isPresented(asTopMost: topMostController, of: UIHostingController<FeatureFlagsView>.self) else {
            return
        }
        
        let view = FeatureFlagsView()
        let controller = UIHostingController(rootView: view)
                
        let navigation = UINavigationController()
        navigation.addChild(controller)
        topMostController.present(navigation, animated: true, completion: nil)
    }
}
