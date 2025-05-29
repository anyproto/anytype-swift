import Foundation

@MainActor
protocol PropertyInfoModuleInput: AnyObject {
    
    func updateRelationFormat(_ newFormat: SupportedPropertyFormat)
    func updateTypesRestriction(objectTypeIds: [String])
    
}
