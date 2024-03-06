import Foundation
import Services

struct TableOfContentsConfiguration: BlockConfiguration {
    typealias View = TableOfContentsView
    
    @EquatableNoop private(set) var contentProviderBuilder: () -> TableOfContentsContentProvider
    @EquatableNoop private(set) var onTap: (String) -> Void
    @EquatableNoop private(set) var blockSetNeedsLayout: () -> Void
}
