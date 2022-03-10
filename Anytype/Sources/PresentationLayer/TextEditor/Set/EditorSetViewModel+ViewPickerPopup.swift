import FloatingPanel
import SwiftUI

extension EditorSetViewModel: AnytypePopupViewModelProtocol {
    var popupLayout: FloatingPanelLayout {
        IntrinsicPopupLayout()
    }
    
    func setContentDelegate(_ сontentDelegate: AnytypePopupContentDelegate) {
        popupDelegate = сontentDelegate
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(rootView: EditorSetViewPicker().environmentObject(self))
    }
}
