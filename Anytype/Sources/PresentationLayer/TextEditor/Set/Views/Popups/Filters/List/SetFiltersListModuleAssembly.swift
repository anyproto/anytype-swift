import SwiftUI
import Services

protocol SetFiltersListModuleAssemblyProtocol {
    @MainActor
    func make(
        with setDocument: SetDocumentProtocol,
        viewId: String,
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
        viewId: String,
        subscriptionDetailsStorage: ObjectDetailsStorage,
        output: SetFiltersListCoordinatorOutput?
    ) -> AnyView {
        return SetFiltersListView(
            viewModel: SetFiltersListViewModel(
                setDocument: setDocument,
                viewId: viewId,
                dataviewService: self.serviceLocator.dataviewService(),
                output: output,
                subscriptionDetailsStorage: subscriptionDetailsStorage
            )
        ).eraseToAnyView()
    }
}
