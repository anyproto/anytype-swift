import SwiftUI

final class ProfileAssembly {
    func profileView() -> some View {
        ProfileView(model: ProfileViewModel(
            authService: ServiceLocator.shared.authService()
        ))
    }
}
