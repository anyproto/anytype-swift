import BlocksModels
import SwiftUI
import Combine
import AnytypeCore

struct MarkupItem: Identifiable, Equatable {
    let id = UUID()
    let markupItem: MarkupAccessoryViewModel.MarkupKind

    static func == (lhs: MarkupItem, rhs: MarkupItem) -> Bool {
        lhs.id == rhs.id
    }

    static var allItems: [MarkupItem] {
        MarkupAccessoryViewModel.MarkupKind.allCases.map {
            MarkupItem(markupItem: $0)
        }
    }
}

final class MarkupAccessoryViewModel: ObservableObject {
    let markupItems: [MarkupItem] = MarkupItem.allItems

    private(set) var restrictions: BlockRestrictions?
    private(set) var actionHandler: BlockActionHandlerProtocol
    private(set) var blockId: BlockId = ""
    private let pageService: PageServiceProtocol
    private let document: BaseDocumentProtocol
    private let linkInTextCoordinator: LinkInTextCoordinatorProtocol

    @Published private(set) var range: NSRange = .zero
    @Published private(set) var currentText: NSAttributedString?
    @Published var showColorView: Bool = false

    var colorButtonFrame: CGRect?

    private var cancellables = [AnyCancellable]()

    init(
        document: BaseDocumentProtocol,
        actionHandler: BlockActionHandlerProtocol,
        pageService: PageServiceProtocol,
        linkInTextCoordinator: LinkInTextCoordinatorProtocol
    ) {
        self.actionHandler = actionHandler
        self.document = document
        self.pageService = pageService
        self.linkInTextCoordinator = linkInTextCoordinator
        self.subscribeOnBlocksChanges()
    }

    func selectBlock(_ info: BlockInformation, text: NSAttributedString, range: NSRange) {
        restrictions = BlockRestrictionsBuilder.build(contentType: info.content.type)
        currentText = text
        blockId = info.id

        updateRange(range: range)
    }

    func updateRange(range: NSRange) {
        self.range = range
    }

    func action(_ markup: MarkupKind) {
        switch markup {
        case .link:
            showLinkToSearch(blockId: blockId, range: range)
        case .color:
            showColorView.toggle()
        case let .fontStyle(fontMarkup):
            actionHandler.changeTextStyle(fontMarkup.markupType, range: range, blockId: blockId)
        }
    }

    func iconColor(for markup: MarkupKind) -> Color {
        let state = attributeState(for: markup)

        switch state {
        case .disabled:
            return .buttonInactive
        case .applied:
            return .buttonSelected
        case .notApplied:
            return .buttonActive
        }
    }

    func handleSelectedColorItem(_ colorItem: ColorView.ColorItem) {
        switch colorItem {
        case let .text(color):
            actionHandler.changeTextStyle(.textColor(color.color), range: range, blockId: blockId)
        case let .background(color):
            actionHandler.changeTextStyle(.backgroundColor(color.color), range: range, blockId: blockId)
        }
    }

    private func attributeState(for markup: MarkupKind) -> AttributeState {
        guard let currentText = currentText else { return .disabled }
        guard let restrictions = restrictions else { return .disabled }

        switch markup {
        case .fontStyle(let fontStyle):
            guard restrictions.isMarkupAvailable(fontStyle.markupType) else { return .disabled }
        case .link, .color:
            guard restrictions.canApplyOtherMarkup else { return .disabled }
        }

        if markup.hasMarkup(for: currentText, range: range) {
            return .applied
        }
        return .notApplied
    }

    private func showLinkToSearch(blockId: BlockId, range: NSRange) {
        guard let currentText = currentText else { return }
        linkInTextCoordinator.startFlow(blockId: blockId, currentText: currentText, range: range)
    }

    private func subscribeOnBlocksChanges() {
        document.updatePublisher.sink { [weak self] update in
            guard let self = self else { return }
            guard case let .blocks(blocks) = update else { return }

            let isCurrentBlock = blocks.contains(where: { blockId in
                blockId == self.blockId
            })

            guard isCurrentBlock, let (block, textBlockContent) = self.blockData(blockId: self.blockId) else { return }

            let currentText = textBlockContent.anytypeText.attrString
            self.selectBlock(block, text: currentText, range: self.range)
        }.store(in: &cancellables)
    }

    private func blockData(blockId: BlockId) -> (BlockInformation, BlockText)? {
        guard let info = document.infoContainer.get(id: blockId) else {
            return nil
        }
        guard case let .text(content) = info.content else {
            return nil
        }
        return (info, content)
    }
}
