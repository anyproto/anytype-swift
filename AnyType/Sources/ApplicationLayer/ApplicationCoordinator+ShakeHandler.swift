import Foundation
import UIKit
import SwiftUI
import Combine
import os

// MARK: Shake Handler
extension ApplicationCoordinator {
    class ShakeHandler {
        var window: UIWindow?
        let developerOptionsService: DeveloperOptionsService = ServiceLocator.shared.resolve()
        private var shakeSubscription: AnyCancellable?
        func configured() -> Self {
            self.shakeSubscription = NotificationCenter.default.publisher(for: .DeviceDidShaked).sink { [weak self] (value) in
                self?.handle()
            }
            // TODO: Integrate Appearance!
            DispatchQueue.main.async {
                let appearance = DeveloperOptions.ViewController.NavigationBar.appearance()
                appearance.tintColor = .black
                appearance.backgroundColor = .white
                appearance.isTranslucent = false
            }
            return self
        }
        init(_ window: UIWindow?) {
            self.window = window
            _ = self.configured()
        }
    }
}

// MARK: Shake Handler / Helpers
extension ApplicationCoordinator.ShakeHandler {
    func isPresented<T>(asTopMost topMostPresented: UIViewController, of type: T.Type) -> Bool where T: UIViewController {
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
}

// MARK: Shake Handler / Handle Action
extension ApplicationCoordinator.ShakeHandler {
    func handle() {
        // check release configuration
//        guard
//            let configuration = PlistReader.BuildConfiguration.create()?.buildConfiguration,
//            configuration != .Release
//            else {
//                print("again, only in debug mode.")
//                return
//            }
        
        // asks if root view controller exists.
        guard let rootViewController = self.window?.rootViewController else {
            os_log(.error, "%s no root view controller!", "\(self)")
            return
        }
        
        // check that we already has this controller.
        // find top presented controller.
        guard let topMostController = self.topPresentedController(for: rootViewController) else {
            os_log(.error, "%s no top most view controller!", "\(self)")
            return
        }
        
        // next, check that it is not already presented.
        guard !self.isPresented(asTopMost: topMostController, of: DeveloperOptions.ViewController.self) else {
            os_log(.error, "%s developer controller is already presented!", "\(self)")
            return
        }
        
        // find correct settings
//        guard let settings = self.developerOptions.current else {
//            print("\(self) settings are not set!")
//            return
//        }
        
        let settings = developerOptionsService.current
        
        let model = DeveloperOptionsViewModel(settings: settings).configured(
            service: developerOptionsService
        )
        let controller = DeveloperOptions.ViewController().configured(model)
                
        let navigation = UINavigationController(navigationBarClass: DeveloperOptions.ViewController.NavigationBar.self, toolbarClass: nil)
        navigation.addChild(controller)
        topMostController.present(navigation, animated: true, completion: nil)
    }
}
