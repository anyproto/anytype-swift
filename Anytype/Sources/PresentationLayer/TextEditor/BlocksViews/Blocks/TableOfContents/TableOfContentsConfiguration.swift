import Foundation
import BlocksModels

struct TableOfContentsConfiguration: BlockConfiguration {
    typealias View = TableOfContentsView
    
    let blockId: BlockId
    @EquatableNoop private(set) var contentProviderBuilder: () -> TableOfContentsContentProvider
    @EquatableNoop private(set) var blockSetNeedsLayout: () -> Void
}
