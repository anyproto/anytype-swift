import Foundation

enum ObjectType: String {
    case page = "_otpage"
    case set = "_otset"
    case template = "_ottemplate"
    case type = "_otobjectType"
    case relation = "_otrelation"
    case profile = "_otprofile"
    case image = "_otimage"
    case file = "_otfile"
    case video = "_otvideo"
    case bug = "_otbug"
    
    var name: String {
        switch self {
        case .page:
            return "Page".localized
        case .set:
            return "Set".localized
        case .template:
            return "Template".localized
        case .type:
            return "Type".localized
        case .relation:
            return "Relation".localized
        case .profile:
            return "Profile".localized
        case .image:
            return "Image".localized
        case .file:
            return "File".localized
        case .video:
            return "Video".localized
        case .bug:
            return "Bug".localized
        }
    }
}
