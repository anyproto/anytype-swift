import SwiftUI

class HomeViewAssembly {
    func createHomeView() -> some View {
        return HomeView(model: HomeViewModel())
    }
}
