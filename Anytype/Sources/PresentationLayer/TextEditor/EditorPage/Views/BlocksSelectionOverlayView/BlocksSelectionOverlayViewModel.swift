import Combine

final class BlocksSelectionOverlayViewModel {
    @Published var navigationTitle: String = ""
    @Published var isBlocksOptionViewVisible: Bool = false

    var endEditingModeHandler: (() -> Void)?

    weak var blocksOptionViewModel: BlocksOptionViewModel?

    func setSelectedBlocksCount(_ count: Int) {
        isBlocksOptionViewVisible = count != 0
        switch count {
        case 1:
            navigationTitle = "\(count) " + "selected block".localized
        default:
            navigationTitle = "\(count) " + "selected blocks".localized
        }
    }
}
