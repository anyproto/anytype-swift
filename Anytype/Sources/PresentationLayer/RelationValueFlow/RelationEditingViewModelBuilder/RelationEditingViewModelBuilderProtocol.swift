import Foundation
import Services

protocol RelationEditingViewModelBuilderProtocol: AnyObject {

    func buildViewModel(
        objectDetails: ObjectDetails,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        onTap: @escaping (_ screenData: EditorScreenData) -> Void
    ) -> AnytypePopupViewModelProtocol?
    
}
