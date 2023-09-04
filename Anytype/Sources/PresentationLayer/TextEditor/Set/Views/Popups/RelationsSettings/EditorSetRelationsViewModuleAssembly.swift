import SwiftUI

protocol EditorSetRelationsViewModuleAssemblyProtocol {
    @MainActor
    // TODO: Remove router with FeatureFlags.newSetSettings
    func make(
        setDocument: SetDocumentProtocol,
        output: EditorSetRelationsCoordinatorOutput?,
        router: EditorSetRouterProtocol?
    ) -> AnyView
}

final class EditorSetRelationsViewModuleAssembly: EditorSetRelationsViewModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - EditorSetRelationsViewModuleAssemblyProtocol
    
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        output: EditorSetRelationsCoordinatorOutput?,
        router: EditorSetRouterProtocol?
    ) -> AnyView {
        let dataviewService = serviceLocator.dataviewService(
            objectId: setDocument.objectId,
            blockId: setDocument.blockId
        )
        return EditorSetRelationsView(
            model: EditorSetRelationsViewModel(
                setDocument: setDocument,
                dataviewService: dataviewService,
                output: output,
                router: router
            )
        ).eraseToAnyView()
    }
}
