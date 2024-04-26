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
    
    @MainActor
    func make(
        objectDetails: ObjectDetails,
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
                objectDetails: objectDetails,
                relation: relation,
                analyticsType: analyticsType,
                onTap: { [weak output] screenData in
                    output?.onTapRelation(screenData: screenData)
                }
            )
        guard let contentViewModel = contentViewModel else { return nil }
        
        return AnytypePopup(viewModel: contentViewModel)
    }
}
