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
            
            let coordinator = OdlHomeCoordinator(
                profileAssembly: ProfileAssembly(),
                editorAssembly: EditorAssembly()
            )
            
            return OldHomeView(
                coordinator: coordinator,
                collectionViewModel: collectionViewModel
            ).eraseToAnyView()
        }
    }
}
