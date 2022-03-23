import FloatingPanel
import SwiftUI

final class SetViewPickerViewModel: ObservableObject, AnytypePopupViewModelProtocol {
    weak var popup: AnytypePopupProxy?
    private let setModel: EditorSetViewModel
    
    init(setModel: EditorSetViewModel) {
        self.setModel = setModel
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
                .environmentObject(setModel)
        )
    }
}
