import SwiftUI
import Services

protocol SetSortsListModuleAssemblyProtocol {
    @MainActor
    func make(with setDocument: SetDocumentProtocol, output: SetSortsListCoordinatorOutput?) -> AnyView
}

final class SetSortsListModuleAssembly: SetSortsListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SetSortsListModuleAssemblyProtocol
    
    @MainActor
    func make(with setDocument: SetDocumentProtocol, output: SetSortsListCoordinatorOutput?) -> AnyView {
        let dataviewService = serviceLocator.dataviewService(
            objectId: setDocument.objectId,
            blockId: setDocument.blockId
        )
        return SetSortsListView(
            viewModel: SetSortsListViewModel(
                setDocument: setDocument,
                dataviewService: dataviewService,
                output: output
            )
        ).eraseToAnyView()
    }
}
