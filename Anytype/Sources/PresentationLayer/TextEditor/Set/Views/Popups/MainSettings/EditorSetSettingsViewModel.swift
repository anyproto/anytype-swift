import FloatingPanel
import SwiftUI

final class EditorSetSettingsViewModel: ObservableObject, AnytypePopupViewModelProtocol {
    weak var popup: AnytypePopupProxy?
    private let onSettingTap: (EditorSetSetting) -> Void
    
    init(onSettingTap: @escaping (EditorSetSetting) -> Void) {
        self.onSettingTap = onSettingTap
    }
    
    func onSettingTap(_ setting: EditorSetSetting) {
        onSettingTap(setting)
    }
    
    // MARK: - AnytypePopupViewModelProtocol
    var popupLayout: AnytypePopupLayoutType {
        .constantHeight(height: 100, floatingPanelStyle: true)
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView: EditorSetSettingsView(model: self)
        )
    }
}
