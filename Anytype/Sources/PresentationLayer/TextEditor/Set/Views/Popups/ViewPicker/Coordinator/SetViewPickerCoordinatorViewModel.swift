import SwiftUI
import Services
import AnytypeCore

@MainActor
protocol SetViewPickerCoordinatorOutput: AnyObject {
    func onAddButtonTap()
    func onEditButtonTap(dataView: DataviewView)
}

@MainActor
final class SetViewPickerCoordinatorViewModel: ObservableObject, SetViewPickerCoordinatorOutput {
    @Published var showSetSettings = false
    
    private let setDocument: SetDocumentProtocol
    private var viewId = ""
    private let setViewPickerModuleAssembly: SetViewPickerModuleAssemblyProtocol
    private let setViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol
    private let subscriptionDetailsStorage: ObjectDetailsStorage
    private let showViewTypes: RoutingAction<DataviewView?>
    
    init(
        setDocument: SetDocumentProtocol,
        setViewPickerModuleAssembly: SetViewPickerModuleAssemblyProtocol,
        setViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol,
        subscriptionDetailsStorage: ObjectDetailsStorage,
        showViewTypes: @escaping RoutingAction<DataviewView?>
    ) {
        self.setDocument = setDocument
        self.setViewPickerModuleAssembly = setViewPickerModuleAssembly
        self.setViewSettingsCoordinatorAssembly = setViewSettingsCoordinatorAssembly
        self.subscriptionDetailsStorage = subscriptionDetailsStorage
        self.showViewTypes = showViewTypes
    }
    
    func list() -> AnyView {
        setViewPickerModuleAssembly.make(
            setDocument: setDocument,
            output: self
        )
    }
    
    // MARK: - SetViewPickerCoordinatorOutput
    
    func onAddButtonTap() {
        showViewTypes(nil)
    }
    
    func onEditButtonTap(dataView: DataviewView) {
        if FeatureFlags.newSetSettings {
            viewId = dataView.id
            showSetSettings.toggle()
        } else {
            showViewTypes(dataView)
        }
    }
    
    func setSettingsView() -> AnyView {
        setViewSettingsCoordinatorAssembly.make(
            setDocument: setDocument,
            viewId: viewId,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
    }
}

extension SetViewPickerCoordinatorViewModel {
    struct AddRelationsData: Identifiable {
        let id = UUID()
        let completion: (RelationDetails, _ isNew: Bool) -> Void
    }
}
