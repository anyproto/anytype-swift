import Foundation

protocol RelationEditingViewModelBuilderProtocol {
    
    func buildViewModel(relation: Relation) -> RelationEditingViewModelProtocol?
    
}
