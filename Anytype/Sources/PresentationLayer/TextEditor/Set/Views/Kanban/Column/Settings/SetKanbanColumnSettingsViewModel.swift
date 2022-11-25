import FloatingPanel
import SwiftUI

final class SetKanbanColumnSettingsViewModel: ObservableObject, AnytypePopupViewModelProtocol {
    @Published var hideColumn: Bool = false
    @Published var selectedColor: BlockBackgroundColor?
    let colors: [BlockBackgroundColor]
    
    weak var popup: AnytypePopupProxy?
    
    init(hideColumn: Bool, selectedColor: BlockBackgroundColor?) {
        self.hideColumn = hideColumn
        self.selectedColor = selectedColor
        self.colors = BlockBackgroundColor.allCases.filter { $0 != .default }
    }
    
    func hideColumnTapped() {
        hideColumn.toggle()
    }
    
    func columnColorTapped(_ newColor: BlockBackgroundColor) {
        selectedColor = newColor
    }
    
    func applyTapped() {
    }
    
    // MARK: - AnytypePopupViewModelProtocol
    var popupLayout: AnytypePopupLayoutType {
        .constantHeight(height: 258, floatingPanelStyle: true)
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView: SetKanbanColumnSettingsView(viewModel: self)
        )
    }
}
