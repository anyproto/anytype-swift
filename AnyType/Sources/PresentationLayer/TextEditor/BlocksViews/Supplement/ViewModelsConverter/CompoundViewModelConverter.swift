import Foundation
import BlocksModels


class CompoundViewModelConverter {
    private weak var document: BaseDocument?
    init(_ document: BaseDocument) {
        self.document = document
    }
    
    func convert(_ blocks: [BlockActiveRecordModelProtocol]) -> [BaseBlockViewModel] {
        blocks.compactMap(self.convert)
    }
    
    func convert(_ block: BlockActiveRecordModelProtocol) -> BaseBlockViewModel? {
        switch block.blockModel.information.content {
        case .smartblock, .layout: return nil
        case let .text(content):
            switch content.contentType {
            case .code:
                return CodeBlockViewModel(block)
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
            let result = BlockPageLinkViewModel(block)
            if let details = document?.getDetails(by: value.targetBlockID) {
                _ = result.configured(details.wholeDetailsPublisher)
            }
            return result
        }
    }
}
