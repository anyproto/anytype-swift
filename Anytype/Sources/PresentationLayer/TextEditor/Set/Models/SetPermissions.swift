import Foundation
import AnytypeCore
import Services

struct SetPermissions {
    var canCreateObject: Bool = false
    var canEditView: Bool  = false
    var canTurnSetIntoCollection: Bool  = false
    var canChangeQuery: Bool  = false
    var canEditRelationValuesInView: Bool = false
}
