import Foundation


enum RelationInfoViewMode {
    case create
    case edit(format: SupportedRelationFormat)
    
    var format: SupportedRelationFormat? {
        switch self {
        case .create:
            nil
        case .edit(let format):
            format
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
