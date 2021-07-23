import SwiftUI

class HomeViewAssembly {
    func createHomeView() -> HomeView {
        HomeView(viewModel: HomeViewModel())
    }
}
