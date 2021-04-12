import SwiftUI

final class HomeViewCoordinator {
    private let profileAssembly: ProfileAssembly
    init(profileAssembly: ProfileAssembly) {
        self.profileAssembly = profileAssembly
    }
    
    func profileView() -> some View {
        profileAssembly.profileView()
    }
}
