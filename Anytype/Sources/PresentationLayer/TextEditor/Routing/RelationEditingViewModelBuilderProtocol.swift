import Foundation
import BlocksModels

protocol RelationEditingViewModelBuilderProtocol {

    func buildViewModel(
        objectId: BlockId,
        relation: NewRelation,
        metadata: RelationMetadata?
    ) -> RelationEditingViewModelProtocol?
    
}
