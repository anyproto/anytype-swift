import Foundation
import BlocksModels

protocol RelationEditingViewModelBuilderProtocol {

    func buildViewModel(
        objectId: BlockId,
        relation: Relation,
        metadata: RelationMetadata?
    ) -> RelationEditingViewModelProtocol2?
    
}
