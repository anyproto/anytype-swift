import Foundation

final class EditorCursorManager {
    private var currentType: String?
    private var didAppearedOnce = false

    func didAppeared(with blocks: [BlockViewModelProtocol], type: String?) {
        currentType = type

        if !didAppearedOnce {
            setFocusOnFirstTextBlock(blocks: blocks)
        }

        didAppearedOnce = true
    }

    func handleGeneralUpdate(with blocks: [BlockViewModelProtocol], type: String?) {
        guard didAppearedOnce, type != self.currentType else {
            return
        }

        self.currentType = type
        setFocusOnFirstTextBlock(blocks: blocks)

    }

    private func setFocusOnFirstTextBlock(blocks: [BlockViewModelProtocol]) {
        if let firstModel = blocks.first(where: { $0.content.isText }),
           firstModel.content.isEmpty {
            (firstModel as? TextBlockViewModel)?.set(focus: .beginning)
        }
    }
}
