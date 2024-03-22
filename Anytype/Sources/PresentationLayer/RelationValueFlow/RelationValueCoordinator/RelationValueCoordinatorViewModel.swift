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
    ObjectRelationListCoordinatorModuleOutput,
    TextRelationActionButtonViewModelDelegate
{
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: ObjectTypeProviderProtocol
    
    var mediumDetent: Bool = false
    
    private let relation: Relation
    private let objectDetails: ObjectDetails
    private let textRelationEditingModuleAssembly: TextRelationEditingModuleAssemblyProtocol
    private let urlOpener: URLOpenerProtocol
    private let analyticsType: AnalyticsEventsRelationType
    private weak var output: RelationValueCoordinatorOutput?

    init(
        relation: Relation,
        objectDetails: ObjectDetails,
        textRelationEditingModuleAssembly: TextRelationEditingModuleAssemblyProtocol,
        urlOpener: URLOpenerProtocol,
        analyticsType: AnalyticsEventsRelationType,
        output: RelationValueCoordinatorOutput?
    ) {
        self.relation = relation
        self.objectDetails = objectDetails
        self.textRelationEditingModuleAssembly = textRelationEditingModuleAssembly
        self.urlOpener = urlOpener
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
            return DateRelationCalendarView(
                date: dateValue,
                configuration: configuration
            ).eraseToAnyView()
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
            let selectedOptionsIds = status.values.compactMap { $0.id }
            return SelectRelationListCoordinatorView(
                data: SelectRelationListData(
                    style: .status,
                    configuration: configuration,
                    relationSelectedOptionsModel: RelationSelectedOptionsModel(
                        config: configuration,
                        selectedOptionsIds: selectedOptionsIds
                    )
                )
            ).eraseToAnyView()
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
            let selectedOptionsIds = tag.selectedTags.compactMap { $0.id }
            return SelectRelationListCoordinatorView(
                data: SelectRelationListData(
                    style: .tag,
                    configuration: configuration,
                    relationSelectedOptionsModel: RelationSelectedOptionsModel(
                        config: configuration,
                        selectedOptionsIds: selectedOptionsIds
                    )
                )
            ).eraseToAnyView()
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
            return ObjectRelationListCoordinatorView(
                data: ObjectRelationListData(
                    configuration: configuration,
                    interactor: ObjectRelationListInteractor(
                        spaceId: configuration.spaceId,
                        limitedObjectTypes: obtainLimitedObjectTypes(with: object.limitedObjectTypes)
                    ),
                    relationSelectedOptionsModel: RelationSelectedOptionsModel(
                        config: configuration, 
                        selectedOptionsIds: object.selectedObjects.compactMap { $0.id }
                    )
                ),
                output: self
            ).eraseToAnyView()
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
            return ObjectRelationListCoordinatorView(
                data: ObjectRelationListData(
                    configuration: configuration,
                    interactor: FileRelationListInteractor(
                        spaceId: configuration.spaceId
                    ),
                    relationSelectedOptionsModel: RelationSelectedOptionsModel(
                        config: configuration, 
                        selectedOptionsIds: file.files.compactMap { $0.id }
                    )
                ),
                output: self
            ).eraseToAnyView()
        }
        
        if FeatureFlags.newTextEditingRelationView, case .text(let text) = relation {
            return textRelationEditingModule(
                value: text.value,
                name: text.name,
                relationKey: text.key,
                type: .text
            )
        }
        
        if FeatureFlags.newTextEditingRelationView, case .number(let number) = relation {
            return textRelationEditingModule(
                value: number.value,
                name: number.name,
                relationKey: number.key,
                type: .number
            )
        }
        
        if FeatureFlags.newTextEditingRelationView, case .email(let email) = relation {
            return textRelationEditingModule(
                value: email.value,
                name: email.name,
                relationKey: email.key,
                type: .email
            )
        }
        
        if FeatureFlags.newTextEditingRelationView, case .phone(let phone) = relation {
            return textRelationEditingModule(
                value: phone.value,
                name: phone.name,
                relationKey: phone.key,
                type: .phone
            )
        }
        
        if FeatureFlags.newTextEditingRelationView, case .url(let url) = relation {
            return textRelationEditingModule(
                value: url.value,
                name: url.name,
                relationKey: url.key,
                type: .url
            )
        }
        
        anytypeAssertionFailure("There is no new module for this relation", info: ["relation": relation.name])
        
        return EmptyView().eraseToAnyView()
    }
    
    private func textRelationEditingModule(
        value: String?,
        name: String,
        relationKey: String,
        type: TextRelationViewType
    ) -> AnyView {
        let configuration = RelationModuleConfiguration(
            title: name,
            isEditable: relation.isEditable,
            relationKey: relationKey,
            objectId: objectDetails.id,
            spaceId: objectDetails.spaceId,
            analyticsType: analyticsType
        )
        return textRelationEditingModuleAssembly.make(
            text: value,
            type: type,
            config: configuration,
            objectDetails: objectDetails,
            output: self
        )
    }
    
    private func obtainLimitedObjectTypes(with typesIds: [String]) -> [ObjectType] {
        typesIds.compactMap { [weak self] id in
            self?.objectTypeProvider.objectTypes.first { $0.id == id }
        }
    }

    
    // MARK: - ObjectRelationListCoordinatorModuleOutput
    
    func onObjectOpen(screenData: EditorScreenData) {
        output?.showEditorScreen(data: screenData)
    }
    
    // MARK: - TextRelationActionButtonViewModelDelegate
    
    func canOpenUrl(_ url: URL) -> Bool {
        urlOpener.canOpenUrl(url)
    }
    
    func openUrl(_ url: URL) {
        urlOpener.openUrl(url)
    }
}
