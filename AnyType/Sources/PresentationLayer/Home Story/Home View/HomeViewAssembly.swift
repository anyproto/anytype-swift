class HomeViewAssembly {
    func createHomeView() -> HomeView {
        let collectionViewModel = HomeCollectionViewModel(
            dashboardService: ServiceLocator.shared.dashboardService(),
            blockActionsService: ServiceLocator.shared.blockActionsServiceSingle()
        )
        
        return HomeView(viewModel: HomeViewModel(), collectionViewModel: collectionViewModel)
    }
}
