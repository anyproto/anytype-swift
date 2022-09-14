import Foundation
import BlocksModels

protocol RelationEditingViewModelBuilderProtocol: AnyObject {

    func buildViewModel(
        source: RelationSource,
        objectId: BlockId,
        relation: Relation,
        onTap: @escaping (_ pageId: BlockId, _ viewType: EditorViewType) -> Void
    ) -> AnytypePopupViewModelProtocol?
    
}
