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

    private func createBlockViewModel(_ block: BlockActiveRecordModelProtocol, router: EditorRouterProtocol?) -> BaseBlockViewModel? {
        switch block.blockModel.information.content {
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
            case .file: return BlocksViews.File.File.ViewModel.init(block)
            case .none: return BlocksViews.Unknown.Label.ViewModel.init(block)
            case .image: return BlocksViews.File.Image.ViewModel.init(block)
            case .video: return VideoBlockViewModel(block)
            }
        case .divider: return DividerBlockViewModel.init(block)
        case .bookmark: return BlocksViews.Bookmark.Bookmark.ViewModel.init(block)
        case let .link(value):
            let result = BlockPageLinkViewModel(block, targetBlockId: value.targetBlockID, router: router)
            if let details = document?.getDetails(by: value.targetBlockID) {
                _ = result.configured(details.wholeDetailsPublisher)
            }
            return result
        }
    }
}
