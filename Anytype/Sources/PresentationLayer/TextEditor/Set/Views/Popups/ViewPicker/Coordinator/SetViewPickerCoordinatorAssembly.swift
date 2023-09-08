import SwiftUI
import Services
import AnytypeCore

protocol SetViewPickerCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        with setDocument: SetDocumentProtocol,
        showViewTypes: @escaping RoutingAction<DataviewView?>
    ) -> AnyView
}

final class SetViewPickerCoordinatorAssembly: SetViewPickerCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - SetViewPickerCoordinatorAssemblyProtocol
    
    @MainActor
    func make(
        with setDocument: SetDocumentProtocol,
        showViewTypes: @escaping RoutingAction<DataviewView?>
    ) -> AnyView {
        return SetViewPickerCoordinatorView(
            model: SetViewPickerCoordinatorViewModel(
                setDocument: setDocument,
                setViewPickerModuleAssembly: self.modulesDI.setViewPicker(),
                showViewTypes: showViewTypes
            )
        ).eraseToAnyView()
    }
}
