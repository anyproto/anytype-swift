import Foundation


enum PropertyInfoViewMode {
    case create(format: SupportedPropertyFormat?)
    case edit(relationId: String, format: SupportedPropertyFormat, limitedObjectTypes: [String]?)
    
    var format: SupportedPropertyFormat? {
        switch self {
        case .create(let format):
            format
        case .edit(_, let format, _):
            format
        }
    }
    
    var relationId: String? {
        switch self {
        case .create:
            nil
        case .edit(let relationId, _, _):
            relationId
        }
    }
    
    var limitedObjectTypes: [String]? {
        switch self {
        case .create:
            nil
        case .edit(_, _, let limitedObjectTypes):
            limitedObjectTypes
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

struct PropertyInfoData: Identifiable {
    let id = UUID()
    let name: String
    let objectId: String?
    let spaceId: String
    let target: PropertiesModuleTarget
    let mode: PropertyInfoViewMode
}
