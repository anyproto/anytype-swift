import Foundation
import UIKit


final class CustomInvalidation: UICollectionViewLayoutInvalidationContext {
    override var invalidatedItemIndexPaths: [IndexPath]? {
        indexPaths
    }
    
    private let indexPaths: [IndexPath]
    
    init(indexPaths: [IndexPath]) {
        self.indexPaths = indexPaths
    }
}
