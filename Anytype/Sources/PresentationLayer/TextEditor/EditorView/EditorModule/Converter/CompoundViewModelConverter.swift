import Foundation
import BlocksModels


final class CompoundViewModelConverter {
    private weak var document: BaseDocumentProtocol?
    private weak var blockActionHandler: NewBlockActionHandler?

    init(document: BaseDocumentProtocol, blockActionHandler: NewBlockActionHandler) {
        self.document = document
        self.blockActionHandler = blockActionHandler
    }

    func convert(_ blocks: [BlockActiveRecordModelProtocol],
                 router: EditorRouterProtocol?,
                 editorViewModel: DocumentEditorViewModel) -> [BaseBlockViewModel] {
        blocks.compactMap { block in
            createBlockViewModel(block, router: router, editorViewModel: editorViewModel)
        }
    }

    private func createBlockViewModel(_ block: BlockActiveRecordModelProtocol,
                                      router: EditorRouterProtocol?,
                                      editorViewModel: DocumentEditorViewModel) -> BaseBlockViewModel? {
        switch block.content {
        case .smartblock, .layout: return nil
        case let .text(content):
            switch content.contentType {
            case .code:
                return CodeBlockViewModel(block, delegate: editorViewModel, actionHandler: blockActionHandler)
            case .toggle:
                return ToggleBlockViewModel(block, blockActionHandler: blockActionHandler, delegate: editorViewModel)
            default:
                return TextBlockViewModel(block, blockActionHandler: blockActionHandler, delegate: editorViewModel)
            }
        case let .file(value):
            switch value.contentType {
            case .file: return BlocksViews.File.File.ViewModel(block, delegate: editorViewModel, router: router, actionHandler: blockActionHandler)
            case .none: return UnknownLabelViewModel(block, delegate: editorViewModel, actionHandler: blockActionHandler)
            case .image: return BlocksViews.File.Image.ViewModel(block, delegate: editorViewModel, router: router, actionHandler: blockActionHandler)
            case .video: return VideoBlockViewModel(block, delegate: editorViewModel, router: router, actionHandler: blockActionHandler)
            }
        case .divider(let content):
            return DividerBlockViewModel(block, content: content, delegate: editorViewModel, actionHandler: blockActionHandler)
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
                targetBlockId: value.targetBlockID,
                publisher: publisher,
                router: router,
                delegate: editorViewModel,
                actionHandler: blockActionHandler
            )
        }
    }
}
