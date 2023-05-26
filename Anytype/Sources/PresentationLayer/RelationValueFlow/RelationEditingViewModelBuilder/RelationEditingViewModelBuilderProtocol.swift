import Foundation
import Services

protocol RelationEditingViewModelBuilderProtocol: AnyObject {

    func buildViewModel(
        objectId: BlockId,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        onTap: @escaping (_ pageId: BlockId, _ viewType: EditorViewType) -> Void
    ) -> AnytypePopupViewModelProtocol?
    
}
