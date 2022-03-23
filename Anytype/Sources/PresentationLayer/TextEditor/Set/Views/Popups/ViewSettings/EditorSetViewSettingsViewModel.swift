import FloatingPanel
import SwiftUI
import ProtobufMessages


final class EditorSetViewSettingsViewModel: ObservableObject, AnytypePopupViewModelProtocol {
    weak var popup: AnytypePopupProxy?
    private let setModel: EditorSetViewModel
    private let service: DataviewServiceProtocol
    
    init(setModel: EditorSetViewModel, service: DataviewServiceProtocol) {
        self.setModel = setModel
        self.service = service
    }
    
    func onShowIconChange(_ show: Bool) {
        let newView = setModel.activeView.updated(hideIcon: !show)
        service.updateView(newView)
    }
    
    // MARK: - AnytypePopupViewModelProtocol
    var popupLayout: AnytypePopupLayoutType {
        .intrinsic
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView: EditorSetViewSettingsView()
                .environmentObject(self)
                .environmentObject(setModel)
        )
    }
}
