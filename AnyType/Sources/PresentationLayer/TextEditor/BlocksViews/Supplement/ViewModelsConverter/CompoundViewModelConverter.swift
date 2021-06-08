import Foundation
import BlocksModels


final class CompoundViewModelConverter {
    private weak var document: BaseDocumentProtocol?

    init(document: BaseDocumentProtocol) {
        self.document = document
    }

    func convert(_ blocks: [BlockActiveRecordModelProtocol], router: EditorRouterProtocol?) -> [BaseBlockViewModel] {
        blocks.compactMap { block in
            createBlockViewModel(block, router: router)
        }
    }

    private func createBlockViewModel(_ block: BlockActiveRecordModelProtocol,
                                      router: EditorRouterProtocol?) -> BaseBlockViewModel? {
        switch block.content {
        case .smartblock, .layout: return nil
        case let .text(content):
            switch content.contentType {
            case .code:
                return CodeBlockViewModel(block)
            case .toggle:
                return ToggleBlockViewModel(block)
            default:
                return TextBlockViewModel(block)
            }
        case let .file(value):
            switch value.contentType {
            case .file: return BlocksViews.File.File.ViewModel(block)
            case .none: return UnknownLabelViewModel(block)
            case .image: return BlocksViews.File.Image.ViewModel(block)
            case .video: return VideoBlockViewModel(block)
            }
        case .divider: return DividerBlockViewModel(block)
        case .bookmark: return BlocksViews.Bookmark.Bookmark.ViewModel(block)
        case let .link(value):
            let publisher = document?.getDetails(by: value.targetBlockID)?.wholeDetailsPublisher
            return BlockPageLinkViewModel(block, targetBlockId: value.targetBlockID, publisher: publisher, router: router)
        }
    }
}
