import SwiftUI

final class ProfileViewCoordinator {
    private let profileService: ProfileService = ServiceLocator.shared.resolve()
    private let authService: AuthService = ServiceLocator.shared.resolve()
    
    lazy private(set) var viewModel = ProfileViewModel(
        profileService: self.profileService,
        authService: self.authService
    )
    
    var profileView: some View {
        ProfileView(model: self.viewModel)
    }
}
