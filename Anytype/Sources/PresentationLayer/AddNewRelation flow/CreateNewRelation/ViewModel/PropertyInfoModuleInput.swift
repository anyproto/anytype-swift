import Foundation

@MainActor
protocol PropertyInfoModuleInput: AnyObject {
    
    func updatePropertyFormat(_ newFormat: SupportedPropertyFormat)
    func updateTypesRestriction(objectTypeIds: [String])
    
}
