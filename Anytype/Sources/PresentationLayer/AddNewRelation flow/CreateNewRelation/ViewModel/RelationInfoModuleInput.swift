import Foundation

@MainActor
protocol RelationInfoModuleInput: AnyObject {
    
    func updateRelationFormat(_ newFormat: SupportedRelationFormat)
    func updateTypesRestriction(objectTypeIds: [String])
    
}
