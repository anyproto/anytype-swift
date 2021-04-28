import Combine
import SwiftUI
import os
import BlocksModels


final class ProfileViewModel: ObservableObject {
    /// Variables / Error
    @Published var error: String = "" {
        didSet {
            self.isShowingError = true
        }
    }
    @Published var isShowingError: Bool = false
    
    /// Device Model
    @Published var updates: Bool = UserDefaultsConfig.notificationUpdates {
        didSet {
            UserDefaultsConfig.notificationUpdates = updates
        }
    }
    @Published var newInvites: Bool = UserDefaultsConfig.notificationNewInvites {
        didSet {
            UserDefaultsConfig.notificationNewInvites = newInvites
        }
    }
    @Published var newComments: Bool = UserDefaultsConfig.notificationNewComments {
        didSet {
            UserDefaultsConfig.notificationNewComments = newComments
        }
    }
    @Published var newDevice: Bool = UserDefaultsConfig.notificationNewDevice {
        didSet {
            UserDefaultsConfig.notificationNewDevice = newDevice
        }
    }
    
    let coordinator = ProfileCoordinator(editorAssembly: EditorAssembly())
    
    private let authService: AuthServiceProtocol
    

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Logout
    func logout() {
        self.authService.logout() {
            InMemoryStoreFacade.clearStorage()
            windowHolder?.startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
        }
    }
}
