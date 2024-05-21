import Foundation
import Services
import SwiftUI
import AnytypeCore

struct SetViewData: Identifiable {
    let id = UUID()
    let document: SetDocumentProtocol
    let subscriptionDetailsStorage: ObjectDetailsStorage
}

@MainActor
final class EditorSetCoordinatorViewModel:
    ObservableObject,
    EditorSetModuleOutput,
    SetObjectCreationCoordinatorOutput,
    ObjectSettingsCoordinatorOutput,
    RelationValueCoordinatorOutput
{
    let data: EditorSetObject
    @Injected(\.legacySetObjectCreationCoordinator)
    private var setObjectCreationCoordinator: SetObjectCreationCoordinatorProtocol
    @Injected(\.legacySetObjectCreationSettingsCoordinator)
    private var setObjectCreationSettingsCoordinator: SetObjectCreationSettingsCoordinatorProtocol
    @Injected(\.relationValueProcessingService)
    private var relationValueProcessingService: RelationValueProcessingServiceProtocol
    
    @Injected(\.legacyToastPresenter)
    private var toastPresenter: ToastPresenterProtocol
    @Injected(\.legacyNavigationContext)
    private var navigationContext: NavigationContextProtocol
    
    var pageNavigation: PageNavigation?
    @Published var dismiss = false
    
    @Published var setViewPickerData: SetViewData?
    @Published var setViewSettingsData: SetSettingsData?
    @Published var setQueryData: SetQueryData?
    @Published var relationValueData: RelationValueData?
    @Published var covertPickerData: ObjectCoverPickerData?
    @Published var toastBarData: ToastBarData = .empty
    @Published var objectIconPickerData: ObjectIconPickerData?
    
    init(data: EditorSetObject) {
        self.data = data
    }
    
    // MARK: - EditorSetModuleOutput
    
    func showEditorScreen(data: EditorScreenData) {
        pageNavigation?.push(data)
    }
    
    func replaceEditorScreen(data: EditorScreenData) {
        pageNavigation?.replace(data)
    }
    
    func closeEditor() {
        dismiss.toggle()
    }
    
    // MARK: - EditorSetModuleOutput - SetViewPicker
    
    func showSetViewPicker(document: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) {
        setViewPickerData = SetViewData(
            document: document,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
    }
    
    // MARK: - EditorSetModuleOutput - SetViewSettings
    
    func showSetViewSettings(document: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) {
        setViewSettingsData = SetSettingsData(
            setDocument: document,
            viewId: document.activeView.id,
            subscriptionDetailsStorage: subscriptionDetailsStorage,
            mode: .edit
        )
    }
    
    // MARK: - EditorSetModuleOutput - SetQuery
    func showQueries(document: SetDocumentProtocol, selectedObjectId: String?, onSelect: @escaping (String) -> ()) {
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
    
    // MARK: - NavigationContext
    
    func showCreateObject(document: SetDocumentProtocol, setting: ObjectCreationSetting?) {
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
        let module = ObjectSettingsCoordinatorView(
            objectId: data.objectId,
            output: self
        )
        let popup = AnytypePopup(contentView: module, floatingPanelStyle: true)
        navigationContext.present(popup)
    }
    
    func showCoverPicker(document: BaseDocumentGeneralProtocol) {
        covertPickerData = ObjectCoverPickerData(document: document)
    }
    
    func showIconPicker(document: BaseDocumentGeneralProtocol) {
        objectIconPickerData = ObjectIconPickerData(document: document)
    }
    
    func showRelationValueEditingView(objectDetails: ObjectDetails, relation: Relation) {
        handleRelationValue(relation: relation, objectDetails: objectDetails)
    }
    
    private func handleRelationValue(relation: Relation, objectDetails: ObjectDetails) {
        relationValueData = relationValueProcessingService.handleRelationValue(
            relation: relation,
            objectDetails: objectDetails,
            analyticsType: .dataview,
            onToastShow: { [weak self] message in
                self?.toastBarData = ToastBarData(text: message, showSnackBar: true, messageType: .none)
            }
        )
    }
    
    func showSetObjectCreationSettings(
        document: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    ) {
        setObjectCreationSettingsCoordinator.showSetObjectCreationSettings(
            setDocument: document,
            viewId: viewId,
            onTemplateSelection: onTemplateSelection
        )
    }
    
    func showFailureToast(message: String) {
        toastBarData = ToastBarData(text: message, showSnackBar: true, messageType: .failure)
    }

    // MARK: - ObjectSettingsCoordinatorOutput
    
    func didCreateTemplate(templateId: String) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
    
    func didCreateLinkToItself(selfName: String, data: EditorScreenData) {
        guard let objectId = data.objectId else { return }
        UIApplication.shared.hideKeyboard()
        toastPresenter.showObjectName(selfName, middleAction: Loc.Editor.Toast.linkedTo, secondObjectId: objectId) { [weak self] in
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
}

extension EditorSetCoordinatorViewModel {
    struct SetQueryData: Identifiable {
        let id = UUID()
        let document: SetDocumentProtocol
        let selectedObjectId: String?
        let onSelect: (String) -> ()
    }
}
