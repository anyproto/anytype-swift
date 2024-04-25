import Foundation

protocol NewRelationModuleInput: AnyObject {
    
    func updateRelationFormat(_ newFormat: SupportedRelationFormat)
    func updateTypesRestriction(objectTypeIds: [String])
    
}
