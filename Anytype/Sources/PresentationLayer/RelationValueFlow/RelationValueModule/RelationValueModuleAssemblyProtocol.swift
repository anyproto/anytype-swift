import Foundation
import BlocksModels
import UIKit

protocol RelationValueModuleAssemblyProtocol: AnyObject {
    
    func make(
        objectId: BlockId,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        delegate: TextRelationActionButtonViewModelDelegate,
        output: RelationValueViewModelOutput
    ) -> UIViewController?
}
