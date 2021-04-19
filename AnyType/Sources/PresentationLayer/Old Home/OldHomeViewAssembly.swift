class OldHomeViewAssembly {
    func createOldHomeView() -> OldHomeView {
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
        )
    }
}
