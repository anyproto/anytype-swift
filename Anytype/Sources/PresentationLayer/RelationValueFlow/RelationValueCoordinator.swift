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
    private let selectRelationListCoordinatorAssembly: SelectRelationListCoordinatorAssemblyProtocol
    private let urlOpener: URLOpenerProtocol
    private let toastPresenter: ToastPresenterProtocol
    private weak var output: RelationValueCoordinatorOutput?
    
    init(
        navigationContext: NavigationContextProtocol,
        relationValueModuleAssembly: RelationValueModuleAssemblyProtocol,
        dateRelationCalendarModuleAssembly: DateRelationCalendarModuleAssemblyProtocol,
        selectRelationListCoordinatorAssembly: SelectRelationListCoordinatorAssemblyProtocol,
        urlOpener: URLOpenerProtocol,
        toastPresenter: ToastPresenterProtocol
    ) {
        self.navigationContext = navigationContext
        self.relationValueModuleAssembly = relationValueModuleAssembly
        self.dateRelationCalendarModuleAssembly = dateRelationCalendarModuleAssembly
        self.selectRelationListCoordinatorAssembly = selectRelationListCoordinatorAssembly
        self.urlOpener = urlOpener
        self.toastPresenter = toastPresenter
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
        
        if FeatureFlags.newDateRelationCalendarView, case .date(let date) = relation {
            let dateValue = date.value?.date
            
            if !relation.isEditable {
                toastPresenter.show(message: Loc.Relation.Date.Locked.Alert.title(relation.name))
                return
            }
            
            let view = dateRelationCalendarModuleAssembly.make(
                objectId: objectDetails.id,
                title: relation.name,
                date: dateValue,
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
        
        if FeatureFlags.newSelectRelationView, case .status(let status) = relation {
            let configuration = RelationModuleConfiguration(
                title: status.name,
                isEditable: relation.isEditable,
                relationKey: status.key,
                spaceId: objectDetails.spaceId,
                analyticsType: analyticsType
            )
            let view = selectRelationListCoordinatorAssembly.make(
                objectId: objectDetails.id,
                configuration: configuration,
                selectedOption: status.values.compactMap {
                    SelectRelationOption(id: $0.id, text: $0.text, color: $0.color.suColor)
                }.first
            )
            
            let mediumDetent = status.values.first.isNotNil || !relation.isEditable
            navigationContext.present(view, mediumDetent: mediumDetent)
            
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
