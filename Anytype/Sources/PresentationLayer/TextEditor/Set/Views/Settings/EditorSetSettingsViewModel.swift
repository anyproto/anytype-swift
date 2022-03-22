import FloatingPanel
import SwiftUI

final class EditorSetSettingsViewModel: ObservableObject, AnytypePopupViewModelProtocol {
    weak var popup: AnytypePopupProxy?
    private var mainModel: EditorSetViewModel
    
    init(mainModel: EditorSetViewModel) {
        self.mainModel = mainModel
    }
    
    func onSettingTap(_ setting: EditorSetSetting) {
        switch setting {
        case .settings:
            // todo
            break
        }
    }
    
    // MARK: - AnytypePopupViewModelProtocol
    var popupLayout: AnytypePopupLayoutType {
        .constantHeight(height: 100, floatingPanelStyle: false)
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView: EditorSetSettingsView()
                .environmentObject(self)
                .environmentObject(mainModel)
        )
    }
}
