import Foundation
import Services
import UIKit


extension BlockContent {
    var indentationStyle: BlockIndentationStyle {
        switch self {
        case .text(let blockText):
            switch blockText.contentType {
            case .quote: return .quote
            case .callout: return .callout
            default: return .none
            }
        default: return .none
        }
    }
}

extension Array where Element == BlockIndentationStyle {
    var totalIndentation: CGFloat {
        reduce(into: CGFloat(0)) { partialResult, f in
            partialResult = partialResult + f.padding
        }
    }
    
    var totalExtraHeight: CGFloat {
        reduce(into: CGFloat(0)) { partialResult, f in
            partialResult = partialResult + f.extraHeight
        }
    }
}

extension UICollectionView {
    var allIndexPaths: [IndexPath] {
        var indexPaths: [IndexPath] = []
        
        for s in 0..<numberOfSections {
            for i in 0..<numberOfItems(inSection: s) {
                indexPaths.append(IndexPath(row: i, section: s))
            }
        }
        
        return indexPaths
    }
}
