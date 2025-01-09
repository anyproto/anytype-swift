import Foundation


enum RelationInfoViewMode {
    case create
    case edit(relationId: String, format: SupportedRelationFormat)
    
    var format: SupportedRelationFormat? {
        switch self {
        case .create:
            nil
        case .edit(_, let format):
            format
        }
    }
    
    var relationId: String? {
        switch self {
        case .create:
            nil
        case .edit(let relationId, _):
            relationId
        }
    }
    
    var canEditRelationType: Bool {
        switch self {
        case .create:
            true
        case .edit:
            false
        }
    }
}

struct RelationInfoData: Identifiable {
    let id = UUID()
    let name: String
    let objectId: String
    let spaceId: String
    let target: RelationsModuleTarget
    let mode: RelationInfoViewMode
}
