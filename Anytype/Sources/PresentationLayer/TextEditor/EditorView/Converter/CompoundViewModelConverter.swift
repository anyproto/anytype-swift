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
        editorViewModel: DocumentEditorViewModel
    ) -> [BaseBlockViewModel] {
        blocks.compactMap { block in
            createBlockViewModel(block, router: router, editorViewModel: editorViewModel)
        }
    }

    private func createBlockViewModel(
        _ block: BlockActiveRecordProtocol,
        router: EditorRouterProtocol,
        editorViewModel: DocumentEditorViewModel
    ) -> BaseBlockViewModel? {
        switch block.content {
        case let .text(content):
            switch content.contentType {
            case .code:
                return CodeBlockViewModel(block, delegate: editorViewModel, actionHandler: blockActionHandler, router: router)
            case .toggle:
                return ToggleBlockViewModel(block, delegate: editorViewModel, actionHandler: blockActionHandler, router: router)
            default:
                return TextBlockViewModel(block, delegate: editorViewModel, actionHandler: blockActionHandler, router: router)
            }
        case let .file(content):
            switch content.contentType {
            case .file:
                return BlocksViewsFileViewModel(
                    block, content: content, delegate: editorViewModel, router: router, actionHandler: blockActionHandler
                )
            case .none:
                return UnknownLabelViewModel(
                    block, delegate: editorViewModel, actionHandler: blockActionHandler, router: router
                )
            case .image:
                return BlocksViewsImageViewModel(
                    block, content: content, delegate: editorViewModel, router: router, actionHandler: blockActionHandler
                )
            case .video:
                return VideoBlockViewModel(
                    block, content: content, delegate: editorViewModel, router: router, actionHandler: blockActionHandler
                )
            }
        case .divider(let content):
            return DividerBlockViewModel(
                block, content: content, delegate: editorViewModel, actionHandler: blockActionHandler, router: router
            )
        case .bookmark:
            return BookmarkViewModel(
                block: block,
                delegate: editorViewModel,
                router: router,
                actionHandler: blockActionHandler
            )
        case let .link(value):
            let publisher = document?.getDetails(by: value.targetBlockID)?.wholeDetailsPublisher

            return BlockPageLinkViewModel(
                block,
                publisher: publisher,
                router: router,
                delegate: editorViewModel,
                actionHandler: blockActionHandler
            )
        case .smartblock, .layout: return nil
        }
    }
}
