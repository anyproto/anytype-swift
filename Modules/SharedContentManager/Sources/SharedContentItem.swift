import Foundation

public enum SharedContentItem: Codable {
    case text(String)
    case url(URL)
    case file(URL)
}

public extension SharedContentItem {
    
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
    
    var isFile: Bool {
        switch self {
        case .file:
            return true
        default:
            return false
        }
    }
}
