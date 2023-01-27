import Foundation
import BlocksModels
import UIKit

final class RelationValueModuleAssembly: RelationValueModuleAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(modulesDI: ModulesDIProtocol, serviceLocator: ServiceLocator) {
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - RelationValueModuleAssemblyProtocol
    
    func make(
        objectId: BlockId,
        relation: Relation,
        delegate: TextRelationActionButtonViewModelDelegate,
        output: RelationValueViewModelOutput
    ) -> UIViewController? {
        
        let contentViewModel = RelationEditingViewModelBuilder(
            delegate: delegate,
            newSearchModuleAssembly: modulesDI.newSearch(),
            searchService: serviceLocator.searchService()
        )
            .buildViewModel(
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
