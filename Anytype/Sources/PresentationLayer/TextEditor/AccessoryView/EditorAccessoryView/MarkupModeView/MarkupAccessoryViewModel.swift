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

    var onShowLinkToObject: RoutingAction<(Either<URL, BlockId>?, (LinkToObjectSearchViewModel.SearchKind) -> ())>?
    var onShowObject: RoutingAction<BlockId>?
    var onShowURL: RoutingAction<URL>?

    private(set) var restrictions: BlockRestrictions?
    private(set) var actionHandler: BlockActionHandlerProtocol
    private(set) var blockId: BlockId = ""
    private let pageService = PageService()
    private let document: BaseDocumentProtocol

    @Published private(set) var range: NSRange = .zero
    @Published private(set) var currentText: NSAttributedString?
    @Published var showColorView: Bool = false

    var colorButtonFrame: CGRect?

    private var cancellables = [AnyCancellable]()

    init(
        document: BaseDocumentProtocol,
        actionHandler: BlockActionHandlerProtocol
    ) {
        self.actionHandler = actionHandler
        self.document = document
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
        let urlLink = currentText?.linkState(range: range)
        let objectIdLink = currentText?.linkToObjectState(range: range)
        let eitherLink: Either<URL, BlockId>? = urlLink.map { .left($0) } ?? objectIdLink.map { .right($0) } ?? nil

        let onLinkSelection: (LinkToObjectSearchViewModel.SearchKind) -> () = { [weak self] searchKind in
            switch searchKind {
            case let .object(linkBlockId):
                self?.actionHandler.setLinkToObject(linkBlockId: linkBlockId, range: range, blockId: blockId)
            case let .createObject(name):
                if let linkBlockId = self?.pageService.createPage(name: name) {
                    AnytypeAnalytics.instance().logCreateObject(objectType: ObjectTypeProvider.shared.defaultObjectType.id, route: .mention)
                    self?.actionHandler.setLinkToObject(linkBlockId: linkBlockId, range: range, blockId: blockId)
                }
            case let .web(url):
                self?.actionHandler.setLink(url: url, range: range, blockId: blockId)
            case let .openURL(url):
                self?.onShowURL?(url)
            case let .openObject(objectId):
                self?.onShowObject?(objectId)
            case .removeLink:
                switch eitherLink {
                case .right:
                    self?.actionHandler.setLinkToObject(linkBlockId: nil, range: range, blockId: blockId)
                case .left:
                    self?.actionHandler.setLink(url: nil, range: range, blockId: blockId)
                default:
                    break
                }
            case let .copyLink(url):
                UIPasteboard.general.string = url.absoluteString
            }
        }

        onShowLinkToObject?((eitherLink, onLinkSelection))
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
