import Combine
import SwiftUI
import os
import BlocksModels


final class ProfileViewModel: ObservableObject {
    let accountData = AccountInfoDataAccessor()
    let coordinator = ProfileCoordinator(editorAssembly: EditorAssembly())
    
    private var authService: AuthServiceProtocol
    
    
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
    
    private var profileViewModelObjectWillChange: AnyCancellable?
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        
        self.profileViewModelObjectWillChange = accountData.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }

    func obtainAccountInfo() {
        accountData.obtainAccountInfo()
    }

    // MARK: - Logout
    func logout() {
        self.authService.logout() {
            windowHolder?.startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
        }
    }
}
