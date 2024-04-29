import SwiftUI
import Services

protocol SetFiltersListCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        with setDocument: SetDocumentProtocol,
        viewId: String,
        subscriptionDetailsStorage: ObjectDetailsStorage
    ) -> AnyView
}

final class SetFiltersListCoordinatorAssembly: SetFiltersListCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(modulesDI: ModulesDIProtocol, coordinatorsDI: CoordinatorsDIProtocol) {
        self.modulesDI = modulesDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetFiltersListCoordinatorAssemblyProtocol
    
    @MainActor
    func make(
        with setDocument: SetDocumentProtocol,
        viewId: String,
        subscriptionDetailsStorage: ObjectDetailsStorage
    ) -> AnyView {
        return SetFiltersListCoordinatorView(
            model: SetFiltersListCoordinatorViewModel(
                setDocument: setDocument,
                viewId: viewId,
                subscriptionDetailsStorage: subscriptionDetailsStorage
            )
        ).eraseToAnyView()
    }
}
