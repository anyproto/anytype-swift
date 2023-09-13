import SwiftUI
import Services
import AnytypeCore

@MainActor
protocol SetViewPickerCoordinatorOutput: AnyObject {
    func onAddButtonTap()
    func onAddButtonTap(with viewId: String)
    func onEditButtonTap(dataView: DataviewView)
}

@MainActor
final class SetViewPickerCoordinatorViewModel: ObservableObject, SetViewPickerCoordinatorOutput {
    @Published var setSettingsData: SetSettingsData?
    
    private let setDocument: SetDocumentProtocol
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
    
    func onAddButtonTap(with viewId: String) {
        setSettingsData = SetSettingsData(
            viewId: viewId,
            mode: .new
        )
    }
    
    func onEditButtonTap(dataView: DataviewView) {
        if FeatureFlags.newSetSettings {
            setSettingsData = SetSettingsData(
                viewId: dataView.id,
                mode: .edit
            )
        } else {
            showViewTypes(dataView)
        }
    }
    
    func setSettingsView(data: SetSettingsData) -> AnyView {
        setViewSettingsCoordinatorAssembly.make(
            setDocument: setDocument,
            viewId: data.viewId,
            mode: data.mode,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
    }
}

extension SetViewPickerCoordinatorViewModel {
    struct SetSettingsData: Identifiable {
        let id = UUID()
        let viewId: String
        let mode: SetViewSettingsMode
    }
}
