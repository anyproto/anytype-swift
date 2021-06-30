import Foundation
import BlocksModels


final class BlockViewModelBuilder {
    private weak var document: BaseDocumentProtocol?
    private let blockActionHandler: EditorActionHandlerProtocol
    private let router: EditorRouterProtocol
    private let delegate: BlockDelegate
    private let contextualMenuHandler: DefaultContextualMenuHandler

    init(
        document: BaseDocumentProtocol,
        blockActionHandler: EditorActionHandlerProtocol,
        router: EditorRouterProtocol,
        delegate: BlockDelegate
    ) {
        self.document = document
        self.blockActionHandler = blockActionHandler
        self.router = router
        self.delegate = delegate
        self.contextualMenuHandler = DefaultContextualMenuHandler(
            handler: blockActionHandler,
            router: router
        )
    }

    func build(_ blocks: [BlockActiveRecordProtocol]) -> [BlockViewModelProtocol] {
        blocks.compactMap { build($0) }
    }

    func build(_ block: BlockActiveRecordProtocol) -> BlockViewModelProtocol? {
        switch block.content {
        case let .text(content):
            switch content.contentType {
            case .code:
                return CodeBlockViewModel(block, delegate: delegate, actionHandler: blockActionHandler, router: router)
            case .toggle:
                return ToggleBlockViewModel(block, delegate: delegate, actionHandler: blockActionHandler, router: router)
            default:
                return TextBlockViewModel(block, delegate: delegate, actionHandler: blockActionHandler, router: router)
            }
        case let .file(content):
            switch content.contentType {
            case .file:
                return BlocksViewsFileViewModel(
                    block, content: content, delegate: delegate, router: router, actionHandler: blockActionHandler
                )
            case .none:
                return UnknownLabelViewModel(
                    block, delegate: delegate, actionHandler: blockActionHandler, router: router
                )
            case .image:
                return BlocksViewsImageViewModel(
                    block, content: content, delegate: delegate, router: router, actionHandler: blockActionHandler
                )
            case .video:
                return VideoBlockViewModel(
                    block, content: content, delegate: delegate, router: router, actionHandler: blockActionHandler
                )
            }
        case .divider(let content):
            return DividerBlockViewModel(
                content: content,
                information: block.blockModel.information,
                handler: contextualMenuHandler
            )
        case .bookmark:
            return BookmarkViewModel(
                block: block,
                delegate: delegate,
                router: router,
                actionHandler: blockActionHandler
            )
        case let .link(value):
            let publisher = document?.getDetails(by: value.targetBlockID)?.wholeDetailsPublisher

            return BlockPageLinkViewModel(
                block,
                publisher: publisher,
                router: router,
                delegate: delegate,
                actionHandler: blockActionHandler
            )
        case .smartblock, .layout: return nil
        }
    }
}
