import UIKit
import BlocksModels

struct BlockBookmarkConfiguration: UIContentConfiguration, Hashable {
    
    let bookmarkData: BlockBookmark
    let imageLoader: BookmarkImageLoader
    
    init(bookmarkData: BlockBookmark, imageLoader: BookmarkImageLoader) {
        self.bookmarkData = bookmarkData
        self.imageLoader = imageLoader
    }
            
    func makeContentView() -> UIView & UIContentView {
        BlockBookmarkContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> BlockBookmarkConfiguration {
        return self
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.bookmarkData == rhs.bookmarkData
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bookmarkData)
    }
    
}
