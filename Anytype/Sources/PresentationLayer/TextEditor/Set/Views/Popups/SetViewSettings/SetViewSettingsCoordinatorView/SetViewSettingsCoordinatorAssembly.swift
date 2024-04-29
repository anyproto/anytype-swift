import SwiftUI
import Services

protocol SetViewSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        with data: SetSettingsData,
        subscriptionDetailsStorage: ObjectDetailsStorage
    ) -> AnyView
}

final class SetViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(modulesDI: ModulesDIProtocol, coordinatorsDI: CoordinatorsDIProtocol) {
        self.modulesDI = modulesDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetViewSettingsCoordinatorModuleAssemblyProtocol
    
    @MainActor
    func make(
        with data: SetSettingsData,
        subscriptionDetailsStorage: ObjectDetailsStorage
    ) -> AnyView {
        return SetViewSettingsCoordinatorView(
            model: SetViewSettingsCoordinatorViewModel(
                data: data,
                subscriptionDetailsStorage: subscriptionDetailsStorage,
                setRelationsCoordinatorAssembly: self.coordinatorsDI.setRelations(),
                setFiltersListCoordinatorAssembly: self.coordinatorsDI.setFiltersList()
            )
        ).eraseToAnyView()
    }
}
