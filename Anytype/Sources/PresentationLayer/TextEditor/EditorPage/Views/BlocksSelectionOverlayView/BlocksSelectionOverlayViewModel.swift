import Combine

enum BlocksSelectionOverlayState {
    case moving
    case simpleTableMenu(selectedBlocksCount: Int)
    case editorMenu(selectedBlocksCount: Int)
    case hidden
}

final class BlocksSelectionOverlayViewModel {
    @Published var navigationTitle: String = ""

    @Published var state: BlocksSelectionOverlayState = .hidden

    var endEditingModeHandler: (() -> Void)?
    var cancelButtonHandler: (() -> Void)?
    var moveButtonHandler: (() -> Void)?
}

