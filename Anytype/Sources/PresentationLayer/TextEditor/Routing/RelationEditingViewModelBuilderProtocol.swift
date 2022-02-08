import Foundation
import BlocksModels

protocol RelationEditingViewModelBuilderProtocol {

    func buildViewModel(objectId: BlockId, relation: Relation) -> RelationEditingViewModelProtocol?
    
}
