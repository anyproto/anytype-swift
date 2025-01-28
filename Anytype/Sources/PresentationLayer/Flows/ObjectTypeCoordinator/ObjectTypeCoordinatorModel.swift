import SwiftUI
import Services


@MainActor
protocol ObjectTypeViewModelOutput: AnyObject, ObjectTypeObjectsListViewModelOutput {
    func onIconTap()
    func onLayoutTap()
    func onFieldsTap()
    func onSyncStatusTap()
    
    func showTemplatesPicker(defaultTemplateId: String)
    func setTemplateAsDefault(templateId: String)
}

@MainActor
protocol  ObjectTypeObjectsListViewModelOutput: AnyObject {
    func onOpenObjectTap(objectId: String)
    func onOpenSetTap(objectId: String)
    func onCreateNewObjectTap()
}

@MainActor
final class ObjectTypeCoordinatorModel: ObservableObject, ObjectTypeViewModelOutput, ObjectTypeObjectsListViewModelOutput {
    @Published var objectIconPickerData: ObjectIconPickerData?
    @Published var layoutPickerObjectId: StringIdentifiable?
    @Published var showTypeFields = false
    @Published var showSyncStatusInfo = false
    
    var pageNavigation: PageNavigation?
    
    @Injected(\.templatesService)
    private var templatesService: any TemplatesServiceProtocol
    @Injected(\.objectActionsService)
    private var objectService: any ObjectActionsServiceProtocol
    
    @Injected(\.legacyTemplatesCoordinator)
    private var templatesCoordinator: any TemplatesCoordinatorProtocol
    @Injected(\.legacyNavigationContext)
    private var navigationContext: any NavigationContextProtocol
    @Injected(\.legacyToastPresenter)
    private var toastPresenter: any ToastPresenterProtocol
    
    let document: any BaseDocumentProtocol
    
    init(data: EditorTypeObject) {
        self.document = Container.shared.documentService().document(objectId: data.objectId, spaceId: data.spaceId)
    }
    
    // MARK: - ObjectTypeViewModelOutput
    func onIconTap() {
        objectIconPickerData = ObjectIconPickerData(document: document)
    }
    
    func onLayoutTap() {
        layoutPickerObjectId = document.objectId.identifiable
    }
    
    func onFieldsTap() {
        showTypeFields.toggle()
    }
    
    func onSyncStatusTap() {
        showSyncStatusInfo.toggle()
    }
    
    func showTemplatesPicker(defaultTemplateId: String) {
        let data = TemplatePickerViewModelData(
            mode: .typeTemplate,
            typeId: document.objectId,
            spaceId: document.spaceId,
            defaultTemplateId: defaultTemplateId
        )
        templatesCoordinator.showTemplatesPicker(
            data: data,
            onSetAsDefaultTempalte: { [weak self] templateId in
                self?.setTemplateAsDefault(templateId: templateId)
            }
        )
    }
    
    func setTemplateAsDefault(templateId: String) {
        Task { @MainActor in
            try? await templatesService.setTemplateAsDefaultForType(objectTypeId: document.objectId, templateId: templateId)
            navigationContext.dismissTopPresented(animated: true, completion: nil)
            toastPresenter.show(message: Loc.Templates.Popup.default)
        }
    }
    
    // MARK: - ObjectTypeObjectsListViewModelOutput
    func onOpenObjectTap(objectId: String) {
        pageNavigation?.open(.editor(.page(EditorPageObject(objectId: objectId, spaceId: document.spaceId))))
    }
    
    func onOpenSetTap(objectId: String) {
        pageNavigation?.open(.editor(.list(EditorListObject(objectId: objectId, spaceId: document.spaceId))))
    }
    
    func onCreateNewObjectTap() {
        Task { @MainActor in
            
            guard let details = document.details else { return }
            let newDetails = try await objectService.createObject(
                name: "",
                typeUniqueKey: details.uniqueKeyValue,
                shouldDeleteEmptyObject: true,
                shouldSelectType: false,
                shouldSelectTemplate: true,
                spaceId: document.spaceId,
                origin: .builtin,
                templateId: details.defaultTemplateId
            )
            
            onOpenObjectTap(objectId: newDetails.id)
        }
    }
}
