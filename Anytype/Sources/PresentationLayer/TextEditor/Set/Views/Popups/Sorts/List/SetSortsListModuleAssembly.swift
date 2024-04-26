import SwiftUI
import Services

protocol SetSortsListModuleAssemblyProtocol {
    @MainActor
    func make(
        with setDocument: SetDocumentProtocol,
        viewId: String,
        output: SetSortsListCoordinatorOutput?
    ) -> AnyView
}

final class SetSortsListModuleAssembly: SetSortsListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SetSortsListModuleAssemblyProtocol
    
    @MainActor
    func make(
        with setDocument: SetDocumentProtocol,
        viewId: String,
        output: SetSortsListCoordinatorOutput?
    ) -> AnyView {
        return SetSortsListView(
            viewModel: SetSortsListViewModel(
                setDocument: setDocument,
                viewId: viewId,
                dataviewService: self.serviceLocator.dataviewService(),
                output: output
            )
        ).eraseToAnyView()
    }
}
