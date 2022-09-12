import Foundation
import BlocksModels
import UIKit

protocol RelationValueModuleAssemblyProtocol: AnyObject {
    
    func make(
        objectId: BlockId,
        source: RelationSource,
        relationValue: RelationValue,
        delegate: TextRelationActionButtonViewModelDelegate,
        output: RelationValueViewModelOutput
    ) -> UIViewController?
}
