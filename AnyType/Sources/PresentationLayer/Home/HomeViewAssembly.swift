import SwiftUI

class HomeViewAssembly {
    func createHomeView() -> HomeView {
        HomeView(model: HomeViewModel())
    }
}
