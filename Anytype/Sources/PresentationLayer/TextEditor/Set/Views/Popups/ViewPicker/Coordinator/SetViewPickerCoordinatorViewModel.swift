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
    private let subscriptionDetailsStorage: ObjectDetailsStorage
    
    init(data: SetViewData) {
        self.setDocument = data.document
        self.subscriptionDetailsStorage = data.subscriptionDetailsStorage
    }
    
    // MARK: - SetViewPickerCoordinatorOutput
    
    func onAddButtonTap(with viewId: String) {
        setSettingsData = SetSettingsData(
            setDocument: setDocument,
            viewId: viewId, 
            subscriptionDetailsStorage: subscriptionDetailsStorage,
            mode: .new
        )
    }
    
    func onEditButtonTap(dataView: DataviewView) {
        setSettingsData = SetSettingsData(
            setDocument: setDocument,
            viewId: dataView.id, 
            subscriptionDetailsStorage: subscriptionDetailsStorage,
            mode: .edit
        )
    }
}
