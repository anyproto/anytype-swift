import SwiftUI

enum TitleWithIconStyle {
    case header
    case gallery
    case list
    
    var titleFont: AnytypeFont {
        switch self {
        case .header: return .title
        case .gallery: return .previewTitle2Medium
        case .list: return .previewTitle1Medium
        }
    }
    
    var lineLimit: Int? {
        switch self {
        case .header: return nil
        case .gallery, .list: return 3
        }
    }
    
    var iconSize: CGSize {
        switch self {
        case .header:
            return CGSize(width: 28, height: 28)
        case .gallery:
            return CGSize(width: 18, height: 18)
        case .list:
            return CGSize(width: 20, height: 20)
        }
    }
}
