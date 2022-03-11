import FloatingPanel
import SwiftUI

extension EditorSetViewModel: AnytypePopupViewModelProtocol {
    var popupLayout: AnytypePopupLayoutType {
        .intrinsic
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(rootView: EditorSetViewPicker().environmentObject(self))
    }
}
