import Foundation

enum ObjectType: String {
    case page = "_otpage"
    case set = "_otset"
    case template = "_ottemplate"
    
    var name: String {
        switch self {
        case .page:
            return "Page".localized
        case .set:
            return "Set".localized
        case .template:
            return "Template".localized
        }
    }
}
