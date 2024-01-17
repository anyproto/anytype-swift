import Foundation

public enum SharedContent: Codable {
    case text(AttributedString)
    case url(URL)
    case image(URL)
}

public extension SharedContent {
    
    var isText: Bool {
        switch self {
        case .text:
            return true
        default:
            return false
        }
    }
    
    var isUrl: Bool {
        switch self {
        case .url:
            return true
        default:
            return false
        }
    }
    
    var isImage: Bool {
        switch self {
        case .image:
            return true
        default:
            return false
        }
    }
}
