import Foundation
import Services
import UIKit
import AnytypeCore

@MainActor
final class RelationValueCoordinator:
    RelationValueCoordinatorProtocol,
    TextRelationActionButtonViewModelDelegate,
    RelationValueViewModelOutput,
    ObjectRelationListCoordinatorModuleOutput
{
    
    private let navigationContext: NavigationContextProtocol
    private let relationValueModuleAssembly: RelationValueModuleAssemblyProtocol
    private let dateRelationCalendarModuleAssembly: DateRelationCalendarModuleAssemblyProtocol
    private let selectRelationListCoordinatorAssembly: SelectRelationListCoordinatorAssemblyProtocol
    private let objectRelationListCoordinatorAssembly: ObjectRelationListCoordinatorAssemblyProtocol
    private let urlOpener: URLOpenerProtocol
    private let toastPresenter: ToastPresenterProtocol
    private weak var output: RelationValueCoordinatorOutput?
    
    init(
        navigationContext: NavigationContextProtocol,
        relationValueModuleAssembly: RelationValueModuleAssemblyProtocol,
        dateRelationCalendarModuleAssembly: DateRelationCalendarModuleAssemblyProtocol,
        selectRelationListCoordinatorAssembly: SelectRelationListCoordinatorAssemblyProtocol,
        objectRelationListCoordinatorAssembly: ObjectRelationListCoordinatorAssemblyProtocol,
        urlOpener: URLOpenerProtocol,
        toastPresenter: ToastPresenterProtocol
    ) {
        self.navigationContext = navigationContext
        self.relationValueModuleAssembly = relationValueModuleAssembly
        self.dateRelationCalendarModuleAssembly = dateRelationCalendarModuleAssembly
        self.selectRelationListCoordinatorAssembly = selectRelationListCoordinatorAssembly
        self.objectRelationListCoordinatorAssembly = objectRelationListCoordinatorAssembly
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
                selectionMode: .single,
                analyticsType: analyticsType
            )
            let view = selectRelationListCoordinatorAssembly.make(
                objectId: objectDetails.id,
                style: .status, 
                configuration: configuration,
                selectedOptionsIds: status.values.compactMap { $0.id }
            )
            
            let mediumDetent = status.values.isNotEmpty || !relation.isEditable
            navigationContext.present(view, mediumDetent: mediumDetent)
            
            return
        }
        
        if FeatureFlags.newMultiSelectRelationView, case .tag(let tag) = relation {
            let configuration = RelationModuleConfiguration(
                title: tag.name,
                isEditable: relation.isEditable,
                relationKey: tag.key,
                spaceId: objectDetails.spaceId, 
                selectionMode: .multi,
                analyticsType: analyticsType
            )
            let view = selectRelationListCoordinatorAssembly.make(
                objectId: objectDetails.id,
                style: .tag,
                configuration: configuration,
                selectedOptionsIds: tag.selectedTags.compactMap { $0.id }
            )
            
            let mediumDetent = tag.selectedTags.isNotEmpty || !relation.isEditable
            navigationContext.present(view, mediumDetent: mediumDetent)
            
            return
        }
        
        if FeatureFlags.newObjectSelectRelationView, case .object(let object) = relation {
            let configuration = RelationModuleConfiguration(
                title: object.name,
                isEditable: relation.isEditable,
                relationKey: object.key,
                spaceId: objectDetails.spaceId,
                selectionMode: .multi,
                analyticsType: analyticsType
            )
            let view = objectRelationListCoordinatorAssembly.make(
                objectId: objectDetails.id, 
                mode: .object(limitedObjectTypes: object.limitedObjectTypes),
                configuration: configuration,
                selectedOptionsIds: object.selectedObjects.compactMap { $0.id }, 
                output: self
            )
            
            let mediumDetent = object.selectedObjects.isNotEmpty || !relation.isEditable
            navigationContext.present(view, mediumDetent: mediumDetent)
            
            return
        }
        
        if FeatureFlags.newFileSelectRelationView, case .file(let file) = relation {
            let configuration = RelationModuleConfiguration(
                title: file.name,
                isEditable: relation.isEditable,
                relationKey: file.key,
                spaceId: objectDetails.spaceId,
                selectionMode: .multi,
                analyticsType: analyticsType
            )
            let view = objectRelationListCoordinatorAssembly.make(
                objectId: objectDetails.id,
                mode: .file,
                configuration: configuration,
                selectedOptionsIds: file.files.compactMap { $0.id },
                output: self
            )
            
            let mediumDetent = file.files.isNotEmpty || !relation.isEditable
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
    
    // MARK: - ObjectRelationListCoordinatorModuleOutput
    
    func onObjectOpen(screenData: EditorScreenData) {
        output?.openObject(screenData: screenData)
    }
}
