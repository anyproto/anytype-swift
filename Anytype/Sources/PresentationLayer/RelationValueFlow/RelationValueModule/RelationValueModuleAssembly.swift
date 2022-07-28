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

final class RelationValueModuleAssembly: RelationValueModuleAssemblyProtocol {
    
    func make(
        objectId: BlockId,
        source: RelationSource,
        relation: Relation,
        delegate: TextRelationActionButtonViewModelDelegate,
        output: RelationValueViewModelOutput
    ) -> UIViewController? {
        
        let contentViewModel = RelationEditingViewModelBuilder(delegate: delegate)
            .buildViewModel(
                source: source,
                objectId: objectId,
                relation: relation,
                onTap: { [weak output] pageId, viewType in
                    output?.onTapRelation(pageId: pageId, viewType: viewType)
                }
            )
        guard let contentViewModel = contentViewModel else { return nil }
        
        return AnytypePopup(viewModel: contentViewModel)
    }
}
