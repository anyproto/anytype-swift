import SwiftUI

final class SetSortsSearchViewPopupModel: AnytypePopupViewModelProtocol {
    
    private let setModel: EditorSetViewModel
    private let onSelect: (_ id: String) -> Void
    
    weak var popup: AnytypePopupProxy?
    
    let popupLayout = AnytypePopupLayoutType.fullScreen
    
    init(setModel: EditorSetViewModel, onSelect: @escaping (_ id: String) -> Void) {
        self.setModel = setModel
        self.onSelect = onSelect
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView: NewSearchModuleAssembly.setSortsSearchModule(
                relations: setModel.relations,
                onSelect: { [weak self] key in
                    self?.onSelect(key)
                    self?.popup?.close()
                }
            )
        )
    }    
}
