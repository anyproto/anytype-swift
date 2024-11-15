import SwiftUI
import Services
import AnytypeCore


struct ObjectTypeViewModelState: Equatable {
    var details: ObjectDetails?
    var relationsCount: Int = 0
    
    var templates = [TemplatePreviewViewModel]()
    var syncStatusData: SyncStatusData?
    
    var showSyncStatusInfo = false
    var isEditorLayout = false
}


@MainActor
final class ObjectTypeViewModel: ObservableObject, RelationsListModuleOutput {
    @Published var state = ObjectTypeViewModelState()
    @Published var toastBarData: ToastBarData = .empty
    @Published var objectIconPickerData: ObjectIconPickerData?
    @Published var layoutPickerObjectId: StringIdentifiable?
    @Published var showFields = false
    
    let data: EditorTypeObject
    let document: any BaseDocumentProtocol
    
    private var defaultTemplateId: String?
    private var rawTemplates: [ObjectDetails] = []
    
    @Injected(\.templatesSubscription)
    private var templatesSubscription: any TemplatesSubscriptionServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.legacyTemplatesCoordinator)
    private var templatesCoordinator: any TemplatesCoordinatorProtocol
    @Injected(\.templatesService)
    private var templatesService: any TemplatesServiceProtocol
    @Injected(\.legacyNavigationContext)
    private var navigationContext: any NavigationContextProtocol
    @Injected(\.legacyToastPresenter)
    private var toastPresenter: any ToastPresenterProtocol
    
    
    init(data: EditorTypeObject) {
        self.data = data
        self.document = Container.shared.documentService().document(objectId: data.objectId, spaceId: data.spaceId)
    }
    
    func setupSubscriptions() async {
        async let detailsSubscription: () = subscribeOnDetails()
        async let templatesSubscription: () = subscribeOnTemplates()
        async let syncStatusSubscription: () = subscribeOnSyncStatus()
        async let fieldsSubscription: () = subscribeOnFields()
        
        (_, _, _, _) = await (detailsSubscription, templatesSubscription, syncStatusSubscription, fieldsSubscription)
    }
    
    func onTemplateTap(model: TemplatePreviewModel) {
        switch model.mode {
        case .installed:
            showTemplatesPicker(defaultTemplateId: model.mode.id)
        case .blank:
            showTemplatesPicker(defaultTemplateId: nil)
        case .addTemplate:
            onAddTemplateTap()
        }
    }
    
    func onSyncStatusTap() {
        state.showSyncStatusInfo.toggle()
    }
    
    func onIconTap() {
        objectIconPickerData = ObjectIconPickerData(document: document)
    }
    
    func onLayoutTap() {
        layoutPickerObjectId = document.objectId.identifiable
    }
    
    func onFieldsTap() {
        showFields.toggle()
    }
    
    // MARK: - Private
    func subscribeOnDetails() async {
        for await details in document.detailsPublisher.values {
            state.details = details
            
            defaultTemplateId = details.defaultTemplateId
            state.isEditorLayout = details.recommendedLayoutValue?.isEditorLayout ?? false
            buildTemplates()
        }
    }
    
    func subscribeOnTemplates() async {
        await templatesSubscription.startSubscription(objectType: data.objectId, spaceId: data.spaceId) { [weak self] rawTemplates in
            guard let self else { return }
            self.rawTemplates = rawTemplates
            buildTemplates()
        }
    }
    
    func subscribeOnSyncStatus() async {
        for await status in document.syncStatusDataPublisher.values {
            state.syncStatusData = SyncStatusData(status: status.syncStatus, networkId: accountManager.account.info.networkId, isHidden: false)
        }
    }
    
    func subscribeOnFields() async {
        for await relations in document.parsedRelationsPublisher.values {
            state.relationsCount = relations.all.count
        }
    }
    
    // Adding ephemeral Blank template and create new template button
    private func buildTemplates() {
        var templates = [TemplatePreviewModel]()
        
        let isBlankTemplateDefault = !rawTemplates.contains { $0.id == defaultTemplateId }
        templates.append(TemplatePreviewModel(
            mode: .blank,
            alignment: .left,
            decoration: isBlankTemplateDefault ? .defaultBadge : nil
        ))
        
        let middlewareTemplates = rawTemplates.map { details in
            let isDefault = details.id == defaultTemplateId
            let decoration: TemplateDecoration? = isDefault ? .defaultBadge : nil
            return TemplatePreviewModel(objectDetails: details, decoration: decoration)
        }
        
        templates += middlewareTemplates

        if state.isEditorLayout {
            templates.append(.init(mode: .addTemplate, alignment: .center))
        }
        
        state.templates = templates.map { model in
            TemplatePreviewViewModel(
                model: model,
                onOptionSelection: { _ in
                    anytypeAssertionFailure("Unsupported call: onOptionSelection")
                }
            )
        }
    }
    
    func onAddTemplateTap() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let templateId = try await templatesService.createTemplateFromObjectType(objectTypeId: data.objectId, spaceId: data.spaceId)
                showTemplatesPicker(defaultTemplateId: templateId)
                toastBarData = ToastBarData(text: Loc.Templates.Popup.WasAddedTo.title(state.details?.title ?? ""), showSnackBar: true)
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Navigation
    private func showTemplatesPicker(defaultTemplateId: String?) {
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
    
    private func setTemplateAsDefault(templateId: String) {
        Task { @MainActor in
            try? await templatesService.setTemplateAsDefaultForType(objectTypeId: document.objectId, templateId: templateId)
            navigationContext.dismissTopPresented(animated: true, completion: nil)
            toastPresenter.show(message: Loc.Templates.Popup.default)
        }
    }
    
    // MARK: - RelationsListModuleOutput
    func addNewRelationAction(document: some BaseDocumentProtocol) {
        // TBD;
    }
    func editRelationValueAction(document: some BaseDocumentProtocol, relationKey: String) {
        // TBD;
    }
    
    func showTypeRelationsView(typeId: String) {
        // TBD;
    }
}
