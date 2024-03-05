import Foundation
import Services
import UIKit
import AnytypeCore

@MainActor
final class LegacyRelationValueCoordinator:
    LegacyRelationValueCoordinatorProtocol,
    TextRelationActionButtonViewModelDelegate,
    RelationValueViewModelOutput,
    ObjectRelationListCoordinatorModuleOutput
{
    
    private let navigationContext: NavigationContextProtocol
    private let relationValueModuleAssembly: RelationValueModuleAssemblyProtocol
    private let dateRelationCalendarModuleAssembly: DateRelationCalendarModuleAssemblyProtocol
    private let selectRelationListCoordinatorAssembly: SelectRelationListCoordinatorAssemblyProtocol
    private let objectRelationListCoordinatorAssembly: ObjectRelationListCoordinatorAssemblyProtocol
    private let relationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol
    private let urlOpener: URLOpenerProtocol
    private let toastPresenter: ToastPresenterProtocol
    private let relationsService: RelationsServiceProtocol
    private weak var output: RelationValueCoordinatorOutput?
    
    init(
        navigationContext: NavigationContextProtocol,
        relationValueModuleAssembly: RelationValueModuleAssemblyProtocol,
        dateRelationCalendarModuleAssembly: DateRelationCalendarModuleAssemblyProtocol,
        selectRelationListCoordinatorAssembly: SelectRelationListCoordinatorAssemblyProtocol,
        objectRelationListCoordinatorAssembly: ObjectRelationListCoordinatorAssemblyProtocol,
        relationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol,
        urlOpener: URLOpenerProtocol,
        toastPresenter: ToastPresenterProtocol,
        relationsService: RelationsServiceProtocol
    ) {
        self.navigationContext = navigationContext
        self.relationValueModuleAssembly = relationValueModuleAssembly
        self.dateRelationCalendarModuleAssembly = dateRelationCalendarModuleAssembly
        self.selectRelationListCoordinatorAssembly = selectRelationListCoordinatorAssembly
        self.objectRelationListCoordinatorAssembly = objectRelationListCoordinatorAssembly
        self.relationValueCoordinatorAssembly = relationValueCoordinatorAssembly
        self.urlOpener = urlOpener
        self.toastPresenter = toastPresenter
        self.relationsService = relationsService
    }
    
    // MARK: - RelationValueCoordinatorProtocol
    
    @MainActor
    func startFlow12(
        objectDetails: ObjectDetails,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        output: RelationValueCoordinatorOutput
    ) {
        self.output = output
        
        if FeatureFlags.newDateRelationCalendarView, case .date = relation, !relation.isEditable {
            toastPresenter.show(message: Loc.Relation.Date.Locked.Alert.title(relation.name))
            return
        }
        
        guard relation.isEditable || relation.hasDetails else { return }
        
        if case .checkbox(let checkbox) = relation {
            let newValue = !checkbox.value
            AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: !newValue, type: analyticsType)
            Task {
                try await relationsService.updateRelation(objectId: objectDetails.id, relationKey: checkbox.key, value: newValue.protobufValue)
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
        output?.showEditorScreen(data: screenData)
    }
    
    // MARK: - ObjectRelationListCoordinatorModuleOutput
    
    func onObjectOpen(screenData: EditorScreenData) {
        output?.showEditorScreen(data: screenData)
    }
}
