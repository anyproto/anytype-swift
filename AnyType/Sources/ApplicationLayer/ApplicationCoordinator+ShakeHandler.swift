//
//  ApplicationCoordinator+ShakeHandler.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 07.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

// MARK: Shake Handler
extension ApplicationCoordinator {
    class ShakeHandler {
        var window: UIWindow?
        @Environment(\.developerOptions) private var developerOptions
        private var shakeSubscription: AnyCancellable?
        func configured() -> Self {
            self.shakeSubscription = NotificationCenter.default.publisher(for: .DeviceDidShaked).sink { [weak self] (value) in
                self?.handle()
            }
            // TODO: Integrate Appearance!
            DispatchQueue.main.async {
                DeveloperOptions.ViewController.NavigationBar.appearance().isTranslucent = false
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
        return sequence(first: controller, next: {$0.presentedViewController}).compactMap{$0}.last
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
            print("\(self) no root view controller!")
            return
        }
        
        // check that we already has this controller.
        // find top presented controller.
        guard let topMostController = self.topPresentedController(for: rootViewController) else {
            print("\(self) no top most view controller!")
            return
        }
        
        // next, check that it is not already presented.
        guard !self.isPresented(asTopMost: topMostController, of: DeveloperOptions.ViewController.self) else {
            print("\(self) developer controller is already presented!")
            return
        }
        
        // find correct settings
//        guard let settings = self.developerOptions.current else {
//            print("\(self) settings are not set!")
//            return
//        }
        
        let settings = self.developerOptions.current
        
        let model = DeveloperOptions.ViewModel(settings: settings).configured(service: self.developerOptions)
        let controller = DeveloperOptions.ViewController().configured(model)
                
        let navigation = UINavigationController(navigationBarClass: DeveloperOptions.ViewController.NavigationBar.self, toolbarClass: nil)
        navigation.addChild(controller)
        topMostController.present(navigation, animated: true, completion: nil)
    }
}
