import Foundation
import BlocksModels
import UIKit

final class RelationValueModuleAssembly: RelationValueModuleAssemblyProtocol {
    
    func make(
        objectId: BlockId,
        source: RelationSource,
        relationValue: RelationValue,
        delegate: TextRelationActionButtonViewModelDelegate,
        output: RelationValueViewModelOutput
    ) -> UIViewController? {
        
        let contentViewModel = RelationEditingViewModelBuilder(delegate: delegate)
            .buildViewModel(
                source: source,
                objectId: objectId,
                relationValue: relationValue,
                onTap: { [weak output] pageId, viewType in
                    output?.onTapRelation(pageId: pageId, viewType: viewType)
                }
            )
        guard let contentViewModel = contentViewModel else { return nil }
        
        return AnytypePopup(viewModel: contentViewModel)
    }
}
