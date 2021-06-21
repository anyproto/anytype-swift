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
                return CodeBlockViewModel(block, delegate: editorViewModel)
            case .toggle:
                return ToggleBlockViewModel(block, blockActionHandler: blockActionHandler, delegate: editorViewModel)
            default:
                return TextBlockViewModel(block, blockActionHandler: blockActionHandler, delegate: editorViewModel)
            }
        case let .file(value):
            switch value.contentType {
            case .file: return BlocksViews.File.File.ViewModel(block, delegate: editorViewModel)
            case .none: return UnknownLabelViewModel(block, delegate: editorViewModel)
            case .image: return BlocksViews.File.Image.ViewModel(block, delegate: editorViewModel)
            case .video: return VideoBlockViewModel(block, delegate: editorViewModel)
            }
        case .divider(let content):
            return DividerBlockViewModel(block, content: content, delegate: editorViewModel)
        case .bookmark:
            return BookmarkViewModel(
                block: block,
                delegate: editorViewModel,
                router: router
            )
        case let .link(value):
            let publisher = document?.getDetails(by: value.targetBlockID)?.wholeDetailsPublisher

            return BlockPageLinkViewModel(
                block,
                targetBlockId: value.targetBlockID,
                publisher: publisher,
                router: router,
                delegate: editorViewModel
            )
        }
    }
}
