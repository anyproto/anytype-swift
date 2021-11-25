import Combine

final class BlocksSelectionOverlayViewModel {
    @Published var navigationTitle: String = ""
    @Published var isBlocksOptionViewVisible: Bool = false
    @Published var isMovingButtonsVisible: Bool = false

    var endEditingModeHandler: (() -> Void)?
    var cancelButtonHandler: (() -> Void)?
    var moveButtonHandler: (() -> Void)?

    weak var blocksOptionViewModel: BlocksOptionViewModel?

    func editorEditingStateDidChanged(_ state: EditorEditingState) {
        switch state {
        case .editing:
            break
        case .moving:
            isMovingButtonsVisible = true
            isBlocksOptionViewVisible = false
            navigationTitle = "Editor.MovingState.ScrollToSelectedPlace".localized
        case .selecting(let blocks):
            isMovingButtonsVisible = false
            isBlocksOptionViewVisible = blocks.isNotEmpty
            switch blocks.count {
            case 1:
                navigationTitle = "\(blocks.count) " + "selected block".localized
            default:
                navigationTitle = "\(blocks.count) " + "selected blocks".localized
            }
        }
    }
}

