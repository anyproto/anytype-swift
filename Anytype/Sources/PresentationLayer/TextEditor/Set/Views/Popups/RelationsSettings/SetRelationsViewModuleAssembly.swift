import SwiftUI

protocol SetRelationsViewModuleAssemblyProtocol {
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        viewId: String,
        output: SetRelationsCoordinatorOutput?
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
        output: SetRelationsCoordinatorOutput?
    ) -> AnyView {
        return SetRelationsView(
            model: SetRelationsViewModel(
                setDocument: setDocument,
                viewId: viewId,
                dataviewService: self.serviceLocator.dataviewService(),
                output: output
            )
        ).eraseToAnyView()
    }
}
