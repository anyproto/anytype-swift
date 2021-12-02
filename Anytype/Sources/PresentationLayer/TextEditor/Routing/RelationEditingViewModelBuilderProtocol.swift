import Foundation
import BlocksModels

protocol RelationEditingViewModelBuilderProtocol {

    func buildViewModel(document: BaseDocumentProtocol, relation: Relation) -> RelationEditingViewModelProtocol?
    
}
