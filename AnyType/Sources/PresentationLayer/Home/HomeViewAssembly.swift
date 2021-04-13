class HomeViewAssembly {
    func createHomeView() -> HomeView {
        let collectionViewModel = HomeCollectionViewModel(
            dashboardService: ServiceLocator.shared.dashboardService(),
            blockActionsService: ServiceLocator.shared.blockActionsServiceSingle()
        )
        
        let coordinator = HomeCoordinator(
            profileAssembly: ProfileAssembly(),
            editorAssembly: EditorAssembly()
        )
        
        return HomeView(
            viewModel: HomeViewModel(coordinator: coordinator),
            collectionViewModel: collectionViewModel
        )
    }
}
