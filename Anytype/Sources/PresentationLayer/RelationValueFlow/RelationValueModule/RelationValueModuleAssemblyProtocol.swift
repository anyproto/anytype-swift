import Foundation
import BlocksModels
import UIKit

protocol RelationValueModuleAssemblyProtocol: AnyObject {
    
    func make(
        objectId: BlockId,
        source: RelationSource,
        relation: Relation,
        delegate: TextRelationActionButtonViewModelDelegate,
        output: RelationValueViewModelOutput
    ) -> UIViewController?
}
