import SwiftUI
import Services

protocol SetViewSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make(setDocument: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) -> AnyView
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
    func make(setDocument: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) -> AnyView {
        return SetViewSettingsCoordinatorView(
            model: SetViewSettingsCoordinatorViewModel(
                setDocument: setDocument,
                subscriptionDetailsStorage: subscriptionDetailsStorage,
                setViewSettingsListModuleAssembly: self.modulesDI.setViewSettingsList(),
                setLayoutSettingsCoordinatorAssembly: self.coordinatorsDI.setLayoutSettings(),
                setFiltersListCoordinatorAssembly: self.coordinatorsDI.setFiltersList(),
                setSortsListCoordinatorAssembly: self.coordinatorsDI.setSortsList()
            )
        ).eraseToAnyView()
    }
}
