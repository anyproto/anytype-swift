import SwiftUI
import Services
import AnytypeCore

protocol SetViewPickerCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        with setDocument: SetDocumentProtocol,
        subscriptionDetailsStorage: ObjectDetailsStorage
    ) -> AnyView
}

final class SetViewPickerCoordinatorAssembly: SetViewPickerCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(modulesDI: ModulesDIProtocol, coordinatorsDI: CoordinatorsDIProtocol) {
        self.modulesDI = modulesDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetViewPickerCoordinatorAssemblyProtocol
    
    @MainActor
    func make(
        with setDocument: SetDocumentProtocol,
        subscriptionDetailsStorage: ObjectDetailsStorage
    ) -> AnyView {
        return SetViewPickerCoordinatorView(
            model: SetViewPickerCoordinatorViewModel(
                setDocument: setDocument,
                setViewSettingsCoordinatorAssembly: self.coordinatorsDI.setViewSettings(),
                subscriptionDetailsStorage: subscriptionDetailsStorage
            )
        ).eraseToAnyView()
    }
}
