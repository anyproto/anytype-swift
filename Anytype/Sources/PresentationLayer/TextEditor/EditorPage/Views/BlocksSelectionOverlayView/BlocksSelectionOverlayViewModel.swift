import Combine

final class BlocksSelectionOverlayViewModel {
    @Published var navigationTitle: String = ""
    @Published var isBlocksOptionViewVisible: Bool = false
    @Published var isMovingButtonsVisible: Bool = false

    var endEditingModeHandler: (() -> Void)?
    var cancelButtonHandler: (() -> Void)?
    var moveButtonHandler: (() -> Void)?

    weak var blocksOptionViewModel: BlocksOptionViewModel?

    func setSelectedBlocksCount(_ count: Int) {
        isMovingButtonsVisible = false
        isBlocksOptionViewVisible = count != 0
        navigationTitle = Loc.selectedBlocks(count)
    }

    func setNeedsUpdateForMovingState() {
        isMovingButtonsVisible = true
        isBlocksOptionViewVisible = false
        navigationTitle = Loc.Editor.MovingState.scrollToSelectedPlace
    }
}

