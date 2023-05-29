import Foundation
import BlocksModels

struct TableOfContentsConfiguration: BlockConfiguration {
    typealias View = TableOfContentsView
    
    @EquatableNoop private(set) var contentProviderBuilder: () -> TableOfContentsContentProvider
    @EquatableNoop private(set) var onTap: (BlockId) -> Void
    @EquatableNoop private(set) var blockSetNeedsLayout: () -> Void
}
