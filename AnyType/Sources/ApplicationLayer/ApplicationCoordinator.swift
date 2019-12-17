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
    
    private let window: UIWindow
    private let keychainStore = KeychainStoreService()
    private let pageScrollViewLayout = GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout()
    // MARK: - Lifecycle
    
    init(window: UIWindow) {
        self.window = window
    }
    
    // MARK: - Public methods
    
    func start() {
        let shouldLogin = true
        if shouldLogin {
            login(id: UserDefaultsConfig.usersIdKey)
        }
        else {
            let view = HomeViewContainer()
            applicationCoordinator?.startNewRootView(content: view)
            
            startNewRootView(content: view)
        }
    }
    
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
                let view = HomeViewContainer()
                self?.startNewRootView(content: view)
            case .failure:
                let view = MainAuthView(viewModel: MainAuthViewModel())
                self?.startNewRootView(content: view)
            }
        }
    }
    
}
