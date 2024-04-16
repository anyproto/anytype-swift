import SwiftUI
import Services

protocol SetViewSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        viewId: String,
        mode: SetViewSettingsMode,
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
        setDocument: SetDocumentProtocol,
        viewId: String,
        mode: SetViewSettingsMode,
        subscriptionDetailsStorage: ObjectDetailsStorage
    ) -> AnyView {
        return SetViewSettingsCoordinatorView(
            model: SetViewSettingsCoordinatorViewModel(
                setDocument: setDocument,
                viewId: viewId,
                mode: mode,
                subscriptionDetailsStorage: subscriptionDetailsStorage,
                setViewSettingsListModuleAssembly: self.modulesDI.setViewSettingsList(),
                setRelationsCoordinatorAssembly: self.coordinatorsDI.setRelations(),
                setFiltersListCoordinatorAssembly: self.coordinatorsDI.setFiltersList(),
                setSortsListCoordinatorAssembly: self.coordinatorsDI.setSortsList()
            )
        ).eraseToAnyView()
    }
}
