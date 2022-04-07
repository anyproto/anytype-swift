import Foundation

protocol NewRelationModuleOutput: AnyObject {
    
    func didAskToShowRelationFormats()
    func didAskToShowObjectTypesSearch(selectedObjectTypesIds: [String])
    
}
