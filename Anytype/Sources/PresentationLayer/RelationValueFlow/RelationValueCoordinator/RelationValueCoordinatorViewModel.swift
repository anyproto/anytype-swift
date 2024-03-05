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
    @Published var imagePreviewData: SheetData?
    @Published var groupByData: SheetData?
    @Published var dismiss: Bool = false
    
    var mediumDetent: Bool = false
    
    private let relation: Relation
    private let objectDetails: ObjectDetails
    private let dateRelationCalendarModuleAssembly: DateRelationCalendarModuleAssemblyProtocol
    private let selectRelationListCoordinatorAssembly: SelectRelationListCoordinatorAssemblyProtocol
    private let objectRelationListCoordinatorAssembly: ObjectRelationListCoordinatorAssemblyProtocol
    private let relationValueModuleAssembly: RelationValueModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let analyticsType: AnalyticsEventsRelationType
    private let toastPresenter: ToastPresenterProtocol
    private let navigationContext: NavigationContextProtocol
    private weak var output: RelationValueCoordinatorOutput?

    init(
        relation: Relation,
        objectDetails: ObjectDetails,
        dateRelationCalendarModuleAssembly: DateRelationCalendarModuleAssemblyProtocol,
        selectRelationListCoordinatorAssembly: SelectRelationListCoordinatorAssemblyProtocol,
        objectRelationListCoordinatorAssembly: ObjectRelationListCoordinatorAssemblyProtocol,
        relationValueModuleAssembly: RelationValueModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        analyticsType: AnalyticsEventsRelationType,
        toastPresenter: ToastPresenterProtocol,
        navigationContext: NavigationContextProtocol,
        output: RelationValueCoordinatorOutput?
    ) {
        self.relation = relation
        self.objectDetails = objectDetails
        self.dateRelationCalendarModuleAssembly = dateRelationCalendarModuleAssembly
        self.selectRelationListCoordinatorAssembly = selectRelationListCoordinatorAssembly
        self.objectRelationListCoordinatorAssembly = objectRelationListCoordinatorAssembly
        self.relationValueModuleAssembly = relationValueModuleAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.analyticsType = analyticsType
        self.toastPresenter = toastPresenter
        self.navigationContext = navigationContext
        self.output = output
    }
    
    func relationModule() -> AnyView {
        guard RelationValueInteractor.canHandleRelation(relation) else {
            anytypeAssertionFailure("There is no new module for this relation", info: ["relation": relation.name])
            return EmptyView().eraseToAnyView()
        }
        
        if case .date(let date) = relation {
            let dateValue = date.value?.date
            return dateRelationCalendarModuleAssembly.make(
                objectId: objectDetails.id,
                title: relation.name,
                date: dateValue,
                relationKey: relation.key,
                analyticsType: analyticsType
            )
        }
        
        if case .status(let status) = relation {
            let configuration = RelationModuleConfiguration(
                title: status.name,
                isEditable: relation.isEditable,
                relationKey: status.key,
                spaceId: objectDetails.spaceId,
                selectionMode: .single,
                analyticsType: analyticsType
            )
            mediumDetent = status.values.isNotEmpty || !relation.isEditable
            return selectRelationListCoordinatorAssembly.make(
                objectId: objectDetails.id,
                style: .status,
                configuration: configuration,
                selectedOptionsIds: status.values.compactMap { $0.id }
            )
        }
        
        if case .tag(let tag) = relation {
            let configuration = RelationModuleConfiguration(
                title: tag.name,
                isEditable: relation.isEditable,
                relationKey: tag.key,
                spaceId: objectDetails.spaceId,
                selectionMode: .multi,
                analyticsType: analyticsType
            )
            mediumDetent = tag.selectedTags.isNotEmpty || !relation.isEditable
            return selectRelationListCoordinatorAssembly.make(
                objectId: objectDetails.id,
                style: .tag,
                configuration: configuration,
                selectedOptionsIds: tag.selectedTags.compactMap { $0.id }
            )
        }
        
        if case .object(let object) = relation {
            let configuration = RelationModuleConfiguration(
                title: object.name,
                isEditable: relation.isEditable,
                relationKey: object.key,
                spaceId: objectDetails.spaceId,
                selectionMode: .multi,
                analyticsType: analyticsType
            )
            mediumDetent = object.selectedObjects.isNotEmpty || !relation.isEditable
            return objectRelationListCoordinatorAssembly.make(
                objectId: objectDetails.id,
                mode: .object(limitedObjectTypes: object.limitedObjectTypes),
                configuration: configuration,
                selectedOptionsIds: object.selectedObjects.compactMap { $0.id },
                output: self
            )
        }
        
        if case .file(let file) = relation {
            let configuration = RelationModuleConfiguration(
                title: file.name,
                isEditable: relation.isEditable,
                relationKey: file.key,
                spaceId: objectDetails.spaceId,
                selectionMode: .multi,
                analyticsType: analyticsType
            )
            mediumDetent = file.files.isNotEmpty || !relation.isEditable
            return objectRelationListCoordinatorAssembly.make(
                objectId: objectDetails.id,
                mode: .file,
                configuration: configuration,
                selectedOptionsIds: file.files.compactMap { $0.id },
                output: self
            )
        }
        
        return EmptyView().eraseToAnyView()
    }
    
    // MARK: - ObjectRelationListCoordinatorModuleOutput
    
    func onObjectOpen(screenData: EditorScreenData) {
        output?.showEditorScreen(data: screenData)
    }
}

extension RelationValueCoordinatorViewModel {
    struct SheetData: Identifiable {
        let id = UUID()
        let completion: (String) -> Void
    }
}

