import Foundation

@MainActor
protocol PropertyInfoModuleInput: AnyObject {
    
    func updateRelationFormat(_ newFormat: SupportedRelationFormat)
    func updateTypesRestriction(objectTypeIds: [String])
    
}
