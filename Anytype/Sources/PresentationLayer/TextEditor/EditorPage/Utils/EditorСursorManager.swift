import BlocksModels

struct BlockFocus {
    let id: BlockId
    let position: BlockFocusPosition
}

final class EditorCursorManager {
    private var currentType: String?
    private var didAppearedOnce = false

    var blockFocus: BlockFocus?

    func didAppeared(with blocks: [EditorItem], type: String?) {
        currentType = type

        if !didAppearedOnce {
            setFocusOnFirstTextBlock(blocks: blocks)
        }

        didAppearedOnce = true
    }

    func handleGeneralUpdate(with blocks: [EditorItem], type: String?) {
        guard didAppearedOnce, type != self.currentType else {
            return
        }

        self.currentType = type
        setFocusOnFirstTextBlock(blocks: blocks)

    }

    private func setFocusOnFirstTextBlock(blocks: [EditorItem]) {
        let firstModel = Array(blocks.prefix(3)).first(applying: { item -> BlockViewModelProtocol? in
            if case let .block(blockViewModel) = item, blockViewModel.content.isText {
                return blockViewModel
            }

            return nil
        })

        if firstModel?.content.isEmpty ?? false {
            firstModel?.set(focus: .beginning)
        }
    }
}
