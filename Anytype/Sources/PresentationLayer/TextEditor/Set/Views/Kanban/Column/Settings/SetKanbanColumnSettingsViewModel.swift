import FloatingPanel
import SwiftUI

final class SetKanbanColumnSettingsViewModel: ObservableObject, AnytypePopupViewModelProtocol {
    @Published var hideColumn: Bool = false
    @Published var selectedColor: BlockBackgroundColor?
    let colors: [BlockBackgroundColor]
    
    private let onApplyTap: (Bool, BlockBackgroundColor?) -> Void
    
    weak var popup: AnytypePopupProxy?
    
    init(
        hideColumn: Bool,
        selectedColor: BlockBackgroundColor?,
        onApplyTap: @escaping (Bool, BlockBackgroundColor?) -> Void)
    {
        self.hideColumn = hideColumn
        self.selectedColor = selectedColor
        self.colors = BlockBackgroundColor.allCases.filter { $0 != .default }
        self.onApplyTap = onApplyTap
    }
    
    func hideColumnTapped() {
        hideColumn.toggle()
    }
    
    func columnColorTapped(_ newColor: BlockBackgroundColor) {
        selectedColor = newColor
    }
    
    func applyTapped() {
        onApplyTap(hideColumn, selectedColor)
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
