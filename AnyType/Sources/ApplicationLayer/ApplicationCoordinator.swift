//
//  ApplicationCoordinator.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit
import SwiftUI
import Combine


/// First coordinator that start ui flow
class ApplicationCoordinator {
    @Environment(\.authService) private var authService
    @Environment(\.localRepoService) private var localRepoService
    @Environment(\.developerOptions) private var developerOptions
    
    private let window: UIWindow
    private let keychainStore = KeychainStoreService()
    private let pageScrollViewLayout = GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout()
    private var shakeHandler: ShakeHandler?
    // MARK: - Lifecycle
    
    init(window: UIWindow) {
        self.window = window
        self.shakeHandler = .init(window)
    }

    // MARK: - Public methods
    
    func start() {
        self.prepareForStart { [weak self] (completed) in
            self?.startBegin()
        }
    }
    
    func startBegin() {
        if developerOptions.current.workflow.authentication.shouldSkipLogin {
            let homeAssembly = HomeViewAssembly()
            let view = homeAssembly.createHomeView()
            self.startNewRootView(content: view)
        }
        else {
            self.login(id: UserDefaultsConfig.usersIdKey)
        }
    }
}

// MARK: Start Preparation.
extension ApplicationCoordinator {
    func runAtFirstTime() {
        if UserDefaultsConfig.installedAtDate == nil {
            UserDefaultsConfig.installedAtDate = .init()
            self.developerOptions.runAtFirstTime()
        }
    }
    
    func prepareForStart(_ completed: @escaping (Bool) -> ()) {
        self.runAtFirstTime()
        completed(true)
    }
}

// MARK: Login
extension ApplicationCoordinator {
    
    func startNewRootView<Content: View>(content: Content) {
        window.rootViewController = UIHostingController(rootView: content.environmentObject(self.pageScrollViewLayout))
        window.makeKeyAndVisible()
    }

    private func login(id: String) {
        guard id.isEmpty == false else {
            let view = MainAuthView(viewModel: MainAuthViewModel())
            startNewRootView(content: view)
            return
        }
        
        self.authService.selectAccount(id: id, path: localRepoService.middlewareRepoPath) { [weak self] result in
            switch result {
            case .success:
                 let homeAssembly = HomeViewAssembly()
                 let view = homeAssembly.createHomeView()
                self?.startNewRootView(content: view)
            case .failure:
                let view = MainAuthView(viewModel: MainAuthViewModel())
                self?.startNewRootView(content: view)
            }
        }
    }
}
