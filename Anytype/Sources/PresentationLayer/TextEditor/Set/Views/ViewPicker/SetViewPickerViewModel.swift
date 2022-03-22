import FloatingPanel
import SwiftUI

final class SetViewPickerViewModel: ObservableObject, AnytypePopupViewModelProtocol {
    weak var popup: AnytypePopupProxy?
    private var mainModel: EditorSetViewModel
    
    init(mainModel: EditorSetViewModel) {
        self.mainModel = mainModel
    }
    
    var popupLayout: AnytypePopupLayoutType {
        .intrinsic
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView: EditorSetViewPicker()
                .environmentObject(self)
                .environmentObject(mainModel)
        )
    }
}
