import UIKit
import SwiftUI
import Combine
import AnytypeCore
import BlocksModels

final class ApplicationCoordinator {
    
    private let windowManager: WindowManager
    private let authService: AuthServiceProtocol
        
    // MARK: - Initializers
    
    init(windowManager: WindowManager, authService: AuthServiceProtocol) {
        self.windowManager = windowManager
        self.authService = authService
    }

    @MainActor
    func start(connectionOptions: UIScene.ConnectionOptions) {
        runAtFirstLaunch()
        login(connectionOptions: connectionOptions)
    }

    @MainActor
    func handleDeeplink(url: URL) {
        switch url {
        case URLConstants.createObjectURL:
            windowManager.createAndShowNewObject()
        default:
            break
        }
    }
}

// MARK: - Private extension

private extension ApplicationCoordinator {
 
    func runAtFirstLaunch() {
        if UserDefaultsConfig.installedAtDate.isNil {
            UserDefaultsConfig.installedAtDate = Date()
        }
    }

    @MainActor
    func login(connectionOptions: UIScene.ConnectionOptions) {
        let userId = UserDefaultsConfig.usersId
        guard userId.isNotEmpty else {
            windowManager.showAuthWindow()
            return
        }
        
        windowManager.showLaunchWindow()
        
        authService.selectAccount(id: userId) { [weak self] result in
            switch result {
            case .active:
                self?.windowManager.showHomeWindow()
            case .pendingDeletion(let deadline):
                self?.windowManager.showDeletedAccountWindow(deadline: deadline)
            case .deleted, .none:
                self?.windowManager.showAuthWindow()
            }

            connectionOptions
                .urlContexts
                .map(\.url)
                .first
                .map { self?.handleDeeplink(url: $0) }
        }
    }
} 
