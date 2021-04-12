class HomeViewAssembly {
    func createHomeView() -> HomeView {
        let viewModel = HomeViewModel(homeCollectionViewAssembly: .init())
        let homeView = HomeView(viewModel: viewModel, collectionViewModel: .init())
        
        return homeView
    }
}
