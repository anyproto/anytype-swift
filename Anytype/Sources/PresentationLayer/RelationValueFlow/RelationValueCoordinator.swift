import Foundation
import Services
import UIKit
import AnytypeCore

final class RelationValueCoordinator: RelationValueCoordinatorProtocol,
                                      TextRelationActionButtonViewModelDelegate,
                                      RelationValueViewModelOutput {
    
    private let navigationContext: NavigationContextProtocol
    private let relationValueModuleAssembly: RelationValueModuleAssemblyProtocol
    private let dateRelationCalendarModuleAssembly: DateRelationCalendarModuleAssemblyProtocol
    private let urlOpener: URLOpenerProtocol
    private weak var output: RelationValueCoordinatorOutput?
    
    init(
        navigationContext: NavigationContextProtocol,
        relationValueModuleAssembly: RelationValueModuleAssemblyProtocol,
        dateRelationCalendarModuleAssembly: DateRelationCalendarModuleAssemblyProtocol,
        urlOpener: URLOpenerProtocol
    ) {
        self.navigationContext = navigationContext
        self.relationValueModuleAssembly = relationValueModuleAssembly
        self.dateRelationCalendarModuleAssembly = dateRelationCalendarModuleAssembly
        self.urlOpener = urlOpener
    }
    
    // MARK: - RelationValueCoordinatorProtocol
    
    @MainActor
    func startFlow(
        objectDetails: ObjectDetails,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        output: RelationValueCoordinatorOutput
    ) {
        self.output = output
        
        guard relation.isEditable || relation.hasDetails else { return }
        
        if case .checkbox(let checkbox) = relation {
            let newValue = !checkbox.value
            AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: !newValue, type: analyticsType)
            let relationsService = RelationsService(objectId: objectDetails.id)
            Task {
                try await relationsService.updateRelation(relationKey: checkbox.key, value: newValue.protobufValue)
            }
            return
        }
        
        if FeatureFlags.newDateRelationCalendarView, case .date(let date) = relation {
            let view = dateRelationCalendarModuleAssembly.make(
                objectId: objectDetails.id,
                title: relation.name,
                date: date.value?.date,
                relationKey: relation.key,
                analyticsType: analyticsType
            )
                        
            if UIDevice.isPad {
                navigationContext.present(view, modalPresentationStyle: .formSheet)
            } else {
                navigationContext.present(view, mediumDetent: true)
            }
            
            return
        }
        
        guard let moduleViewController = relationValueModuleAssembly.make(
            objectDetails: objectDetails,
            relation: relation,
            analyticsType: analyticsType,
            delegate: self,
            output: self
        ) else { return }
        
        navigationContext.present(moduleViewController, animated: true)
    }
    
    // MARK: - TextRelationActionButtonViewModelDelegate
    
    func canOpenUrl(_ url: URL) -> Bool {
        urlOpener.canOpenUrl(url)
    }
    
    func openUrl(_ url: URL) {
        urlOpener.openUrl(url)
    }
    
    // MARK: - RelationValueViewModelOutput
    
    func onTapRelation(screenData: EditorScreenData) {
        output?.openObject(screenData: screenData)
    }
}
