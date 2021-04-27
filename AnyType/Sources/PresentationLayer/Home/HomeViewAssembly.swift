import SwiftUI

class HomeViewAssembly {
    func createHomeView() -> some View {
        if FeatureFlags.newHome {
            return HomeView(model: HomeViewModel()).eraseToAnyView()
        } else {
            let collectionViewModel = OldHomeCollectionViewModel(
                dashboardService: ServiceLocator.shared.dashboardService(),
                blockActionsService: ServiceLocator.shared.blockActionsServiceSingle()
            )
            
            return OldHomeView(
                coordinator: ServiceLocator.shared.homeCoordinator(),
                collectionViewModel: collectionViewModel
            ).eraseToAnyView()
        }
    }
}
