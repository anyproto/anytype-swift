import SwiftUI
import Services

protocol SetFiltersListModuleAssemblyProtocol {
    @MainActor
    func make(
        with setDocument: SetDocumentProtocol,
        subscriptionDetailsStorage: ObjectDetailsStorage,
        output: SetFiltersListCoordinatorOutput?
    ) -> AnyView
}

final class SetFiltersListModuleAssembly: SetFiltersListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SetFiltersListModuleAssemblyProtocol
    
    @MainActor
    func make(
        with setDocument: SetDocumentProtocol,
        subscriptionDetailsStorage: ObjectDetailsStorage,
        output: SetFiltersListCoordinatorOutput?
    ) -> AnyView {
        let dataviewService = serviceLocator.dataviewService(
            objectId: setDocument.objectId,
            blockId: setDocument.inlineParameters?.blockId
        )
        return SetFiltersListView(
            viewModel: SetFiltersListViewModel(
                setDocument: setDocument,
                dataviewService: dataviewService,
                output: output,
                subscriptionDetailsStorage: subscriptionDetailsStorage
            )
        ).eraseToAnyView()
    }
}
