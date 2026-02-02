import FloatingPanel
import SwiftUI

@MainActor
@Observable
final class SetKanbanColumnSettingsViewModel: AnytypePopupViewModelProtocol {
    var hideColumn: Bool = false
    var selectedColor: BlockBackgroundColor?
    let colors: [BlockBackgroundColor]

    @ObservationIgnored
    private let onApplyTap: (Bool, BlockBackgroundColor?) -> Void

    @ObservationIgnored
    weak var popup: (any AnytypePopupProxy)?
    
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
    
    func onPopupInstall(_ popup: some AnytypePopupProxy) {
        self.popup = popup
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView: SetKanbanColumnSettingsView(viewModel: self)
        )
    }
}
