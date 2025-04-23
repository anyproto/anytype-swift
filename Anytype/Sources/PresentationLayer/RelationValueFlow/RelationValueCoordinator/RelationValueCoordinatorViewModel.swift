import SwiftUI
import Services
import AnytypeCore

@MainActor
protocol RelationValueCoordinatorOutput: AnyObject {
    func showEditorScreen(data: ScreenData)
}

@MainActor
final class RelationValueCoordinatorViewModel: 
    ObservableObject,
    ObjectRelationListCoordinatorModuleOutput,
    TextRelationActionButtonViewModelDelegate
{
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectDateByTimestampService)
    private var objectDateByTimestampService: any ObjectDateByTimestampServiceProtocol
    
    var mediumDetent: Bool = false
    
    private let relation: Relation
    private let objectDetails: ObjectDetails
    private let analyticsType: AnalyticsEventsRelationType
    private weak var output: (any RelationValueCoordinatorOutput)?

    @Published var toastBarData: ToastBarData?
    @Published var safariUrl: URL?
    
    init(data: RelationValueData, output: (any RelationValueCoordinatorOutput)?) {
        self.relation = data.relation
        self.objectDetails = data.objectDetails
        self.analyticsType = data.analyticsType
        self.output = output
    }
    
    func relationModule() -> AnyView {
        switch relation {
        case .date(let date):
            return dateModule(date: date)
        case .status(let status):
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
        case .tag(let tag):
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
        case .object(let object):
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
        case .file(let file):
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
        case .text(let text):
            return textRelationEditingModule(
                value: text.value,
                name: text.name,
                relationKey: text.key,
                type: .text
            )
        case .number(let number):
            return textRelationEditingModule(
                value: number.value,
                name: number.name,
                relationKey: number.key,
                type: .number
            )
        case .url(let url):
            return textRelationEditingModule(
                value: url.value,
                name: url.name,
                relationKey: url.key,
                type: .url
            )
        case .email(let email):
            return textRelationEditingModule(
                value: email.value,
                name: email.name,
                relationKey: email.key,
                type: .email
            )
        case .phone(let phone):
            return textRelationEditingModule(
                value: phone.value,
                name: phone.name,
                relationKey: phone.key,
                type: .phone
            )
        case .unknown, .checkbox:
            anytypeAssertionFailure("There is no module for this relation", info: ["relation": relation.name])
            return EmptyView().eraseToAnyView()
        }
    }
    
    private func dateModule(date: Relation.Date) -> AnyView {
        if date.isEditable {
            let dateValue = date.value?.date
            let configuration = RelationModuleConfiguration(
                title: date.name,
                isEditable: relation.isEditable,
                relationKey: date.key,
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
                analyticsType: analyticsType
            )
            return RelationCalendarCoordinatorView(
                date: dateValue,
                configuration: configuration
            ).eraseToAnyView()
        } else {
            let dateValue = date.value?.date ?? Date()
            return DateCoordinatorView(
                data: EditorDateObject(
                    date: dateValue,
                    spaceId: objectDetails.spaceId
                )
            ).applyDragIndicator().eraseToAnyView()
        }
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
        
        return TextRelationEditingView(
            data: TextRelationEditingViewData(
                text: value,
                type: type,
                config: configuration,
                objectDetails: objectDetails,
                output: self
            )
        ).eraseToAnyView()
    }
    
    private func obtainLimitedObjectTypes(with typesIds: [String]) -> [ObjectType] {
        typesIds.compactMap { try? objectTypeProvider.objectType(id: $0) }
    }

    
    // MARK: - ObjectRelationListCoordinatorModuleOutput
    
    func onObjectOpen(screenData: ScreenData) {
        output?.showEditorScreen(data: screenData)
    }
    
    // MARK: - TextRelationActionButtonViewModelDelegate
    
    func canOpenUrl(_ url: URL) -> Bool {
        UIApplication.shared.canOpenURL(url.urlByAddingHttpIfSchemeIsEmpty())
    }
    
    func openUrl(_ url: URL) {
        safariUrl = url
    }
    
    func showActionSuccessMessage(_ text: String) {
        toastBarData = ToastBarData(text, type: .success)
    }
}
