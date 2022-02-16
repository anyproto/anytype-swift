import Foundation
import BlocksModels

protocol RelationEditingViewModelBuilderProtocol {

    func buildViewModel(source: RelationSource, objectId: BlockId, relation: Relation) -> RelationDetailsViewModelProtocol?
    
}
