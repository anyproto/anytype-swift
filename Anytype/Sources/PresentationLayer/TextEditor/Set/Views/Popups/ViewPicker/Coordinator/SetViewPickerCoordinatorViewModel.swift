import SwiftUI
import Services
import AnytypeCore

@MainActor
protocol SetViewPickerCoordinatorOutput: AnyObject {
    func onAddButtonTap(with viewId: String)
    func onEditButtonTap(dataView: DataviewView)
}

@MainActor
final class SetViewPickerCoordinatorViewModel: ObservableObject, SetViewPickerCoordinatorOutput {
    @Published var setSettingsData: SetSettingsData?
    
    let setDocument: SetDocumentProtocol
    private let setViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol
    private let subscriptionDetailsStorage: ObjectDetailsStorage
    
    init(
        setDocument: SetDocumentProtocol,
        setViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol,
        subscriptionDetailsStorage: ObjectDetailsStorage
    ) {
        self.setDocument = setDocument
        self.setViewSettingsCoordinatorAssembly = setViewSettingsCoordinatorAssembly
        self.subscriptionDetailsStorage = subscriptionDetailsStorage
    }
    
    // MARK: - SetViewPickerCoordinatorOutput
    
    func onAddButtonTap(with viewId: String) {
        setSettingsData = SetSettingsData(
            setDocument: setDocument,
            viewId: viewId,
            mode: .new
        )
    }
    
    func onEditButtonTap(dataView: DataviewView) {
        setSettingsData = SetSettingsData(
            setDocument: setDocument,
            viewId: dataView.id,
            mode: .edit
        )
    }
    
    func setSettingsView(data: SetSettingsData) -> AnyView {
        setViewSettingsCoordinatorAssembly.make(
            with: SetSettingsData(
                setDocument: setDocument,
                viewId: data.viewId,
                mode: data.mode
            ),
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
    }
}
