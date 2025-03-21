import Foundation
import Services
import SwiftUI
import AnytypeCore

struct SetViewData: Identifiable {
    let id = UUID()
    let document: any SetDocumentProtocol
    let subscriptionDetailsStorage: ObjectDetailsStorage
}

struct LayoutPickerData: Identifiable {
    let objectId: String
    let spaceId: String
    let analyticsType: AnalyticsObjectType
    
    var id: String {
        "\(objectId)-\(spaceId)"
    }
}

@MainActor
final class EditorSetCoordinatorViewModel:
    ObservableObject,
    EditorSetModuleOutput,
    SetObjectCreationCoordinatorOutput,
    ObjectSettingsCoordinatorOutput,
    RelationValueCoordinatorOutput,
    SetObjectCreationSettingsOutput
{
    let data: EditorListObject
    let showHeader: Bool
    @Injected(\.legacySetObjectCreationCoordinator)
    private var setObjectCreationCoordinator: any SetObjectCreationCoordinatorProtocol
    @Injected(\.legacySetObjectCreationSettingsCoordinator)
    private var legacySetObjectCreationSettingsCoordinator: any SetObjectCreationSettingsCoordinatorProtocol
    @Injected(\.relationValueProcessingService)
    private var relationValueProcessingService: any RelationValueProcessingServiceProtocol
    @Injected(\.templatesService)
    private var templatesService: any TemplatesServiceProtocol
    @Injected(\.detailsService)
    private var detailsService: any DetailsServiceProtocol
    
    @Injected(\.legacyToastPresenter)
    private var toastPresenter: any ToastPresenterProtocol
    @Injected(\.legacyNavigationContext)
    private var navigationContext: any NavigationContextProtocol
    @Injected(\.legacyTemplatesCoordinator)
    private var templatesCoordinator: any TemplatesCoordinatorProtocol
    
    var pageNavigation: PageNavigation?
    var dismissAllPresented: DismissAllPresented?
    @Published var dismiss = false
    
    @Published var setViewPickerData: SetViewData?
    @Published var setViewSettingsData: SetSettingsData?
    @Published var setQueryData: SetQueryData?
    @Published var relationValueData: RelationValueData?
    @Published var covertPickerData: BaseDocumentIdentifiable?
    @Published var toastBarData: ToastBarData = .empty
    @Published var objectIconPickerData: ObjectIconPickerData?
    @Published var syncStatusSpaceId: StringIdentifiable?
    @Published var setObjectCreationData: SetObjectCreationData?
    @Published var presentSettings = false
    @Published var layoutPickerData: LayoutPickerData?
    @Published var showTypeFieldsDocument: BaseDocumentIdentifiable?
    @Published var templatesPickerDocument: BaseDocumentIdentifiable?
    @Published var objectTypeInfo: ObjectTypeInfo?
    
    init(data: EditorListObject, showHeader: Bool) {
        self.data = data
        self.showHeader = showHeader
    }
    
    // MARK: - EditorSetModuleOutput
    
    func showEditorScreen(data: ScreenData) {
        pageNavigation?.open(data)
    }
    
    func replaceEditorScreen(data: EditorScreenData) {
        pageNavigation?.replace(data)
    }
    
    func closeEditor() {
        dismiss.toggle()
    }
    
    // MARK: - EditorSetModuleOutput - SetViewPicker
    
    func showSetViewPicker(document: some SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) {
        setViewPickerData = SetViewData(
            document: document,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
    }
    
    // MARK: - EditorSetModuleOutput - SetViewSettings
    
    func showSetViewSettings(document: some SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) {
        setViewSettingsData = SetSettingsData(
            setDocument: document,
            viewId: document.activeView.id,
            subscriptionDetailsStorage: subscriptionDetailsStorage,
            mode: .edit
        )
    }
    
    // MARK: - EditorSetModuleOutput - SetQuery
    func showQueries(document: some SetDocumentProtocol, selectedObjectId: String?, onSelect: @escaping (String) -> ()) {
        setQueryData = SetQueryData(
            document: document,
            selectedObjectId: selectedObjectId,
            onSelect: onSelect
        )
    }
    func setQuery(_ queryData: SetQueryData) -> ObjectTypeSearchView {
        ObjectTypeSearchView(
            title: Loc.Set.SourceType.selectQuery,
            spaceId: data.spaceId,
            settings: .queryInSet
        ) { [weak self] type in
            queryData.onSelect(type.id)
            self?.setQueryData = nil
        }
    }
    
    // MARK: - Primitives - Object type
    func showTypeInfoEditor(info: ObjectTypeInfo) {
        self.objectTypeInfo = info
    }
    
    func onObjectTypeNameUpdate(info: ObjectTypeInfo) {
        Task {
            try await detailsService.updateBundledDetails(objectId: data.objectId, bundledDetails: .builder {
                BundledDetails.name(info.singularName)
                BundledDetails.pluralName(info.pluralName)
                BundledDetails.iconName(info.icon?.stringRepresentation ?? "")
                BundledDetails.iconOption(info.color?.iconOption ?? CustomIconColor.default.iconOption)
            })
        }
    }
    
    // MARK: - NavigationContext
    
    func showCreateObject(document: some SetDocumentProtocol, setting: ObjectCreationSetting?) {
        setObjectCreationCoordinator.startCreateObject(setDocument: document, setting: setting, output: self, customAnalyticsRoute: nil)
    }
    
    func showKanbanColumnSettings(
        hideColumn: Bool,
        selectedColor: BlockBackgroundColor?,
        onSelect: @escaping (Bool, BlockBackgroundColor?) -> Void
    ) {
        let popup = AnytypePopup(
            viewModel: SetKanbanColumnSettingsViewModel(
                hideColumn: hideColumn,
                selectedColor: selectedColor,
                onApplyTap: { [weak self] hidden, backgroundColor in
                    onSelect(hidden, backgroundColor)
                    self?.navigationContext.dismissTopPresented()
                }
            ),
            configuration: .init(
                isGrabberVisible: true,
                dismissOnBackdropView: true
            )
        )
        navigationContext.present(popup)
    }
    
    func showSettings() {
        presentSettings = true
    }
    
    func showCoverPicker(document: some BaseDocumentProtocol) {
        covertPickerData = BaseDocumentIdentifiable(document: document)
    }
    
    func showIconPicker(document: some BaseDocumentProtocol) {
        objectIconPickerData = ObjectIconPickerData(document: document)
    }
    
    func showRelationValueEditingView(objectDetails: ObjectDetails, relation: Relation) {
        handleRelationValue(relation: relation, objectDetails: objectDetails)
    }
    
    private func handleRelationValue(relation: Relation, objectDetails: ObjectDetails) {
        relationValueData = relationValueProcessingService.handleRelationValue(
            relation: relation,
            objectDetails: objectDetails,
            analyticsType: .dataview
        )
    }
    
    func showSetObjectCreationSettings(
        document: some SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    ) {
        setObjectCreationData = SetObjectCreationData(
            setDocument: document,
            viewId: viewId,
            onTemplateSelection: { [weak self] setting in
                self?.syncDismissAllPresented {
                    onTemplateSelection(setting)
                }                
            }
        )
    }
    
    func showFailureToast(message: String) {
        toastBarData = ToastBarData(text: message, showSnackBar: true, messageType: .failure)
    }
    
    func showSyncStatusInfo(spaceId: String) {
        syncStatusSpaceId = spaceId.identifiable
    }

    // MARK: - ObjectSettingsCoordinatorOutput
    
    func didCreateTemplate(templateId: String) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
    
    func didCreateLinkToItself(selfName: String, data: ScreenData) {
        guard let objectId = data.objectId else { return }
        UIApplication.shared.hideKeyboard()
        toastPresenter.showObjectName(selfName, middleAction: Loc.Editor.Toast.linkedTo, secondObjectId: objectId, spaceId: data.spaceId) { [weak self] in
            Task { [weak self] in
                self?.showEditorScreen(data: data)
            }
        }
    }
    
    func didTapUseTemplateAsDefault(templateId: String) {
        anytypeAssertionFailure("Invalid delegate method handler")
    }
    
    func didUndoRedo() {
        anytypeAssertionFailure("Undo/redo is not available")
    }
    
    func versionRestored(_ text: String) {
        toastBarData = ToastBarData(text: Loc.VersionHistory.Toast.message(text), showSnackBar: true, messageType: .none)
    }
    
    // MARK: - SetObjectCreationSettingsOutput
    
    func onObjectTypesSearchAction(setDocument: some SetDocumentProtocol, completion: @escaping (ObjectType) -> Void) {
        legacySetObjectCreationSettingsCoordinator.onObjectTypesSearchAction(setDocument: setDocument, completion: completion)
    }
    
    func templateEditingHandler(
        setting: ObjectCreationSetting,
        onSetAsDefaultTempalte: @escaping (String) -> Void,
        onTemplateSelection: ((ObjectCreationSetting) -> Void)?
    ) {
        legacySetObjectCreationSettingsCoordinator.templateEditingHandler(setting: setting, onSetAsDefaultTempalte: onSetAsDefaultTempalte, onTemplateSelection: onTemplateSelection)
    }
    
    func onObjectTypeLayoutTap(_ data: LayoutPickerData) {
        layoutPickerData = data
    }
    
    func onObjectTypeFieldsTap(document: some SetDocumentProtocol) {
        AnytypeAnalytics.instance().logScreenEditType(route: .type)
        showTypeFieldsDocument = document.document.identifiable
    }
    
    func onObjectTypeTemplatesTap(document: some SetDocumentProtocol) {
        templatesPickerDocument = document.document.identifiable
    }
    
    func onObjectTypeSingleTemplateTap(objectId: String, spaceId: String, defaultTemplateId: String?) {
        let data = TemplatePickerViewModelData(
            mode: .typeTemplate,
            typeId: objectId,
            spaceId: spaceId,
            defaultTemplateId: defaultTemplateId
        )

        templatesCoordinator.showTemplatesPicker(
            data: data,
            onSetAsDefaultTempalte: { [weak self] templateId in
                self?.setTemplateAsDefault(objectId: objectId, templateId: templateId)
            }
        )
    }
    
    private func setTemplateAsDefault(objectId: String, templateId: String) {
        Task { @MainActor in
            try? await templatesService.setTemplateAsDefaultForType(objectTypeId: objectId, templateId: templateId)
            navigationContext.dismissTopPresented(animated: true, completion: nil)
            toastPresenter.show(message: Loc.Templates.Popup.default)
        }
    }
    
    // MARK: - Private
    
    func syncDismissAllPresented(completion: @escaping () -> Void) {
        Task { @MainActor in
            await dismissAllPresented?()
            completion()
        }
    }
}

extension EditorSetCoordinatorViewModel {
    struct SetQueryData: Identifiable {
        let id = UUID()
        let document: any SetDocumentProtocol
        let selectedObjectId: String?
        let onSelect: (String) -> ()
    }
}
