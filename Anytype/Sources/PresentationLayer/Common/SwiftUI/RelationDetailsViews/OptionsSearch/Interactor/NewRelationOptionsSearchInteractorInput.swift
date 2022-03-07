import Foundation

protocol NewRelationOptionsSearchInteractorInput {
    
    func obtainOptions(for text: String, onCompletion: ([RelationOptionsSearchItem]) -> Void)
    
}
