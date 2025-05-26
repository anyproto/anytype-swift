import SwiftUI
import Services
import AnytypeCore

@MainActor
protocol PropertyValueCoordinatorOutput: AnyObject {
    func showEditorScreen(data: ScreenData)
}

@MainActor
final class PropertyValueCoordinatorViewModel: 
    ObservableObject,
    ObjectPropertyListCoordinatorModuleOutput,
    TextPropertyActionButtonViewModelDelegate
{
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectDateByTimestampService)
    private var objectDateByTimestampService: any ObjectDateByTimestampServiceProtocol
    
    var mediumDetent: Bool = false
    
    private let relation: Relation
    private let objectDetails: ObjectDetails
    private let analyticsType: AnalyticsEventsRelationType
    private weak var output: (any PropertyValueCoordinatorOutput)?

    @Published var toastBarData: ToastBarData?
    @Published var safariUrl: URL?
    
    init(data: PropertyValueData, output: (any PropertyValueCoordinatorOutput)?) {
        self.relation = data.relation
        self.objectDetails = data.objectDetails
        self.analyticsType = data.analyticsType
        self.output = output
    }
    
    func propertyModule() -> AnyView {
        switch relation {
        case .date(let date):
            return dateModule(date: date)
        case .status(let status):
            let configuration = PropertyModuleConfiguration(
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
            return SelectPropertyListCoordinatorView(
                data: SelectPropertyListData(
                    style: .status,
                    configuration: configuration,
                    relationSelectedOptionsModel: PropertySelectedOptionsModel(
                        config: configuration,
                        selectedOptionsIds: selectedOptionsIds
                    )
                )
            ).eraseToAnyView()
        case .tag(let tag):
            let configuration = PropertyModuleConfiguration(
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
            return SelectPropertyListCoordinatorView(
                data: SelectPropertyListData(
                    style: .tag,
                    configuration: configuration,
                    relationSelectedOptionsModel: PropertySelectedOptionsModel(
                        config: configuration,
                        selectedOptionsIds: selectedOptionsIds
                    )
                )
            ).eraseToAnyView()
        case .object(let object):
            let configuration = PropertyModuleConfiguration(
                title: object.name,
                isEditable: relation.isEditable,
                relationKey: object.key,
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
                selectionMode: .multi,
                analyticsType: analyticsType
            )
            mediumDetent = object.selectedObjects.isNotEmpty || !relation.isEditable
            return ObjectPropertyListCoordinatorView(
                data: ObjectPropertyListData(
                    configuration: configuration,
                    interactor: ObjectPropertyListInteractor(
                        spaceId: configuration.spaceId,
                        limitedObjectTypes: obtainLimitedObjectTypes(with: object.limitedObjectTypes)
                    ),
                    relationSelectedOptionsModel: PropertySelectedOptionsModel(
                        config: configuration,
                        selectedOptionsIds: object.selectedObjects.compactMap { $0.id }
                    )
                ),
                output: self
            ).eraseToAnyView()
        case .file(let file):
            let configuration = PropertyModuleConfiguration(
                title: file.name,
                isEditable: relation.isEditable,
                relationKey: file.key,
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
                selectionMode: .multi,
                analyticsType: analyticsType
            )
            mediumDetent = file.files.isNotEmpty || !relation.isEditable
            return ObjectPropertyListCoordinatorView(
                data: ObjectPropertyListData(
                    configuration: configuration,
                    interactor: FilePropertyListInteractor(
                        spaceId: configuration.spaceId
                    ),
                    relationSelectedOptionsModel: PropertySelectedOptionsModel(
                        config: configuration,
                        selectedOptionsIds: file.files.compactMap { $0.id }
                    )
                ),
                output: self
            ).eraseToAnyView()
        case .text(let text):
            return textPropertyEditingModule(
                value: text.value,
                name: text.name,
                relationKey: text.key,
                type: .text
            )
        case .number(let number):
            return textPropertyEditingModule(
                value: number.value,
                name: number.name,
                relationKey: number.key,
                type: .number
            )
        case .url(let url):
            return textPropertyEditingModule(
                value: url.value,
                name: url.name,
                relationKey: url.key,
                type: .url
            )
        case .email(let email):
            return textPropertyEditingModule(
                value: email.value,
                name: email.name,
                relationKey: email.key,
                type: .email
            )
        case .phone(let phone):
            return textPropertyEditingModule(
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
            let configuration = PropertyModuleConfiguration(
                title: date.name,
                isEditable: relation.isEditable,
                relationKey: date.key,
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
                analyticsType: analyticsType
            )
            return PropertyCalendarCoordinatorView(
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
    
    private func textPropertyEditingModule(
        value: String?,
        name: String,
        relationKey: String,
        type: TextPropertyViewType
    ) -> AnyView {
        let configuration = PropertyModuleConfiguration(
            title: name,
            isEditable: relation.isEditable,
            relationKey: relationKey,
            objectId: objectDetails.id,
            spaceId: objectDetails.spaceId,
            analyticsType: analyticsType
        )
        
        return TextPropertyEditingView(
            data: TextPropertyEditingViewData(
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

    
    // MARK: - ObjectPropertyListCoordinatorModuleOutput
    
    func onObjectOpen(screenData: ScreenData) {
        output?.showEditorScreen(data: screenData)
    }
    
    // MARK: - TextPropertyActionButtonViewModelDelegate
    
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
