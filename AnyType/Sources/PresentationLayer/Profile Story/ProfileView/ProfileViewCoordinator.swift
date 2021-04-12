import SwiftUI

final class ProfileViewCoordinator {
    private let profileService = ServiceLocator.shared.profileService()
    private let authService = ServiceLocator.shared.authService()
    
    lazy private(set) var viewModel = ProfileViewModel(
        authService: self.authService
    )
    
    var profileView: some View {
        ProfileView(model: self.viewModel)
    }
}
