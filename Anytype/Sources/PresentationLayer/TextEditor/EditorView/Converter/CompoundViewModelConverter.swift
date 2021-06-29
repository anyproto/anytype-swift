import Foundation
import BlocksModels


final class CompoundViewModelConverter {
    private weak var document: BaseDocumentProtocol?
    private let blockActionHandler: EditorActionHandlerProtocol

    init(document: BaseDocumentProtocol, blockActionHandler: EditorActionHandlerProtocol) {
        self.document = document
        self.blockActionHandler = blockActionHandler
    }

    func convert(
        _ blocks: [BlockActiveRecordProtocol],
        router: EditorRouterProtocol,
        delegate: BlockDelegate
    ) -> [BlockViewModelProtocol] {
        blocks.compactMap { block in
            createBlockViewModel(block, router: router, delegate: delegate)
        }
    }

    private func createBlockViewModel(
        _ block: BlockActiveRecordProtocol,
        router: EditorRouterProtocol,
        delegate: BlockDelegate
    ) -> BlockViewModelProtocol? {
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
                block, content: content, delegate: delegate, actionHandler: blockActionHandler, router: router
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
