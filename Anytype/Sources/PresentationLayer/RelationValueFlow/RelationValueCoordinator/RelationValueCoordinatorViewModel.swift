import SwiftUI
import Services
import AnytypeCore

@MainActor
protocol RelationValueCoordinatorOutput: AnyObject {
    func showEditorScreen(data: EditorScreenData)
}

@MainActor
final class RelationValueCoordinatorViewModel: 
    ObservableObject,
    ObjectRelationListCoordinatorModuleOutput
{
    var mediumDetent: Bool = false
    
    private let relation: Relation
    private let objectDetails: ObjectDetails
    private let dateRelationCalendarModuleAssembly: DateRelationCalendarModuleAssemblyProtocol
    private let selectRelationListCoordinatorAssembly: SelectRelationListCoordinatorAssemblyProtocol
    private let objectRelationListCoordinatorAssembly: ObjectRelationListCoordinatorAssemblyProtocol
    private let textRelationEditingModuleAssembly: TextRelationEditingModuleAssemblyProtocol
    private let analyticsType: AnalyticsEventsRelationType
    private weak var output: RelationValueCoordinatorOutput?

    init(
        relation: Relation,
        objectDetails: ObjectDetails,
        dateRelationCalendarModuleAssembly: DateRelationCalendarModuleAssemblyProtocol,
        selectRelationListCoordinatorAssembly: SelectRelationListCoordinatorAssemblyProtocol,
        objectRelationListCoordinatorAssembly: ObjectRelationListCoordinatorAssemblyProtocol,
        textRelationEditingModuleAssembly: TextRelationEditingModuleAssemblyProtocol,
        analyticsType: AnalyticsEventsRelationType,
        output: RelationValueCoordinatorOutput?
    ) {
        self.relation = relation
        self.objectDetails = objectDetails
        self.dateRelationCalendarModuleAssembly = dateRelationCalendarModuleAssembly
        self.selectRelationListCoordinatorAssembly = selectRelationListCoordinatorAssembly
        self.objectRelationListCoordinatorAssembly = objectRelationListCoordinatorAssembly
        self.textRelationEditingModuleAssembly = textRelationEditingModuleAssembly
        self.analyticsType = analyticsType
        self.output = output
    }
    
    func relationModule() -> AnyView {
        if FeatureFlags.newDateRelationCalendarView, case .date(let date) = relation {
            let dateValue = date.value?.date
            let configuration = RelationModuleConfiguration(
                title: date.name,
                isEditable: relation.isEditable,
                relationKey: date.key,
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
                analyticsType: analyticsType
            )
            return dateRelationCalendarModuleAssembly.make(
                date: dateValue,
                configuration: configuration
            )
        }
        
        if FeatureFlags.newSelectRelationView, case .status(let status) = relation {
            let configuration = RelationModuleConfiguration(
                title: status.name,
                isEditable: relation.isEditable,
                relationKey: status.key,
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
                selectionMode: .single,
                analyticsType: analyticsType
            )
            mediumDetent = status.values.isNotEmpty || !relation.isEditable
            return selectRelationListCoordinatorAssembly.make(
                style: .status,
                configuration: configuration,
                selectedOptionsIds: status.values.compactMap { $0.id }
            )
        }
        
        if FeatureFlags.newMultiSelectRelationView, case .tag(let tag) = relation {
            let configuration = RelationModuleConfiguration(
                title: tag.name,
                isEditable: relation.isEditable,
                relationKey: tag.key,
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
                selectionMode: .multi,
                analyticsType: analyticsType
            )
            mediumDetent = tag.selectedTags.isNotEmpty || !relation.isEditable
            return selectRelationListCoordinatorAssembly.make(
                style: .tag,
                configuration: configuration,
                selectedOptionsIds: tag.selectedTags.compactMap { $0.id }
            )
        }
        
        if FeatureFlags.newObjectSelectRelationView, case .object(let object) = relation {
            let configuration = RelationModuleConfiguration(
                title: object.name,
                isEditable: relation.isEditable,
                relationKey: object.key,
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
                selectionMode: .multi,
                analyticsType: analyticsType
            )
            mediumDetent = object.selectedObjects.isNotEmpty || !relation.isEditable
            return objectRelationListCoordinatorAssembly.make(
                mode: .object(limitedObjectTypes: object.limitedObjectTypes),
                configuration: configuration,
                selectedOptionsIds: object.selectedObjects.compactMap { $0.id },
                output: self
            )
        }
        
        if FeatureFlags.newObjectSelectRelationView, case .file(let file) = relation {
            let configuration = RelationModuleConfiguration(
                title: file.name,
                isEditable: relation.isEditable,
                relationKey: file.key,
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
                selectionMode: .multi,
                analyticsType: analyticsType
            )
            mediumDetent = file.files.isNotEmpty || !relation.isEditable
            return objectRelationListCoordinatorAssembly.make(
                mode: .file,
                configuration: configuration,
                selectedOptionsIds: file.files.compactMap { $0.id },
                output: self
            )
        }
        
        if FeatureFlags.newTextEditingRelationView, case .text(let text) = relation {
            let configuration = RelationModuleConfiguration(
                title: text.name,
                isEditable: relation.isEditable,
                relationKey: text.key,
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
                analyticsType: analyticsType
            )
            return textRelationEditingModuleAssembly.make(
                text: text.value, 
                type: .text,
                config: configuration
            )
        }
        
        if FeatureFlags.newTextEditingRelationView, case .number(let number) = relation {
            let configuration = RelationModuleConfiguration(
                title: number.name,
                isEditable: relation.isEditable,
                relationKey: number.key,
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
                analyticsType: analyticsType
            )
            return textRelationEditingModuleAssembly.make(
                text: number.value,
                type: .number,
                config: configuration
            )
        }
        
        anytypeAssertionFailure("There is no new module for this relation", info: ["relation": relation.name])
        
        return EmptyView().eraseToAnyView()
    }
    
    // MARK: - ObjectRelationListCoordinatorModuleOutput
    
    func onObjectOpen(screenData: EditorScreenData) {
        output?.showEditorScreen(data: screenData)
    }
}
