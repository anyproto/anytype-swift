class HomeViewAssembly {
    func createHomeView() -> HomeView {
        return HomeView(viewModel: HomeViewModel(), collectionViewModel: HomeCollectionViewModel())
    }
}
