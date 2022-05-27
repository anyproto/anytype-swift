import FloatingPanel
import SwiftUI

final class EditorSetSettingsViewModel: ObservableObject, AnytypePopupViewModelProtocol {
    weak var popup: AnytypePopupProxy?
    private let setModel: EditorSetViewModel
    
    init(setModel: EditorSetViewModel) {
        self.setModel = setModel
    }
    
    func onSettingTap(_ setting: EditorSetSetting) {
        switch setting {
        case .settings:
            setModel.showViewSettings()
        case .sort:
            setModel.showSorts()
        }
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
            rootView: EditorSetSettingsView()
                .environmentObject(self)
        )
    }
}
