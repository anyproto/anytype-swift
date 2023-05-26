import Foundation
import Services
import UIKit

final class RelationValueModuleAssembly: RelationValueModuleAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(modulesDI: ModulesDIProtocol, serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - RelationValueModuleAssemblyProtocol
    
    func make(
        objectId: BlockId,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        delegate: TextRelationActionButtonViewModelDelegate,
        output: RelationValueViewModelOutput
    ) -> UIViewController? {
        
        let contentViewModel = RelationEditingViewModelBuilder(
            delegate: delegate,
            newSearchModuleAssembly: modulesDI.newSearch(),
            searchService: serviceLocator.searchService(),
            systemURLService: serviceLocator.systemURLService(),
            alertOpener: uiHelpersDI.alertOpener(),
            bookmarkService: serviceLocator.bookmarkService()
        )
            .buildViewModel(
                objectId: objectId,
                relation: relation,
                analyticsType: analyticsType,
                onTap: { [weak output] pageId, viewType in
                    output?.onTapRelation(pageId: pageId, viewType: viewType)
                }
            )
        guard let contentViewModel = contentViewModel else { return nil }
        
        return AnytypePopup(viewModel: contentViewModel)
    }
}
