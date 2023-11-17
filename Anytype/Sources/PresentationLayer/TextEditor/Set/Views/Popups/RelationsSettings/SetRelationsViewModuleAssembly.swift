import SwiftUI

protocol SetRelationsViewModuleAssemblyProtocol {
    @MainActor
    // TODO: Remove router with FeatureFlags.newSetSettings
    func make(
        setDocument: SetDocumentProtocol,
        viewId: String,
        output: SetRelationsCoordinatorOutput?,
        router: EditorSetRouterProtocol?
    ) -> AnyView
}

final class SetRelationsViewModuleAssembly: SetRelationsViewModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - EditorSetRelationsViewModuleAssemblyProtocol
    
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        viewId: String,
        output: SetRelationsCoordinatorOutput?,
        router: EditorSetRouterProtocol?
    ) -> AnyView {
        let dataviewService = serviceLocator.dataviewService(
            objectId: setDocument.objectId,
            blockId: setDocument.inlineParameters?.blockId
        )
        return SetRelationsView(
            model: SetRelationsViewModel(
                setDocument: setDocument,
                viewId: viewId,
                dataviewService: dataviewService,
                output: output,
                router: router
            )
        ).eraseToAnyView()
    }
}
