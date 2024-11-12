import SwiftUI
import Services


@MainActor
final class ObjectTypeViewModel: ObservableObject {
    @Published var title = ""
    @Published var templates = [TemplatePreviewViewModel]()
    @Published var syncStatusData: SyncStatusData?
    
    @Published var showSyncStatusInfo = false
    
    let data: EditorTypeObject
    
    private let document: any BaseDocumentProtocol
    private var isTemplatesEditable = false
    private var rawTemplates: [ObjectDetails] = []
    
    @Injected(\.templatesSubscription)
    private var templatesSubscription: any TemplatesSubscriptionServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.legacyTemplatesCoordinator)
    private var templatesCoordinator: any TemplatesCoordinatorProtocol
    
    init(data: EditorTypeObject) {
        self.data = data
        self.document = Container.shared.documentService().document(objectId: data.objectId, spaceId: data.spaceId)
    }
    
    func setupSubscriptions() async {
        async let detailsSubscription: () = subscribeOnDetails()
        async let templatesSubscription: () = subscribeOnTemplates()
        async let syncStatusSubscription: () = subscribeOnSyncStatus()
        
        (_, _, _) = await (detailsSubscription, templatesSubscription, syncStatusSubscription)
    }
    
    func onTemplateTap(model: TemplatePreviewModel) {
        switch model.mode {
        case .installed, .blank:
            showTemplatesPicker() // TODO: Preserve selected template
        case .addTemplate:
            onAddTemplateTap()
        }
    }
    
    func onSyncStatusTap() {
        showSyncStatusInfo.toggle()
    }
    
    // MARK: - Private
    func subscribeOnDetails() async {
        for await details in document.detailsPublisher.values {
            title = details.title
            
            let isEditorLayout = details.recommendedLayoutValue?.isEditorLayout ?? false
            if isEditorLayout != isTemplatesEditable {
                isTemplatesEditable = isEditorLayout
                updateTemplates()
            }
        }
    }
    
    func subscribeOnTemplates() async {
        await templatesSubscription.startSubscription(objectType: data.objectId, spaceId: data.spaceId) { [weak self] rawTemplates in
            guard let self else { return }
            self.rawTemplates = rawTemplates
            updateTemplates()
        }
    }
    
    func subscribeOnSyncStatus() async {
        for await status in document.syncStatusDataPublisher.values {
            syncStatusData = SyncStatusData(status: status.syncStatus, networkId: accountManager.account.info.networkId, isHidden: false)
        }
    }
    
    // Adding ephemeral Blank template
    private func updateTemplates() {
        let middlewareTemplates = rawTemplates.map { TemplatePreviewModel(objectDetails: $0, decoration: nil) } // TBD: isDefault
        var templates = [TemplatePreviewModel]()
        
//        let isBlankTemplateDefault = !middlewareTemplates.contains { $0.isDefault }
        templates.append(TemplatePreviewModel(mode: .blank, alignment: .left, decoration: .defaultBadge))
        
        templates += middlewareTemplates

        if isTemplatesEditable {
            templates.append(.init(mode: .addTemplate, alignment: .center))
        }
        
        self.templates = templates.map { model in
            TemplatePreviewViewModel(
                model: model,
                onOptionSelection: { [weak self] option in
                    self?.handleTemplateOption(option: option, templateViewModel: model)
                }
            )
        }
    }
    
    private func handleTemplateOption(
        option: TemplateOptionAction,
        templateViewModel: TemplatePreviewModel
    ) {
        // TBD;
    }
    
    private func onAddTemplateTap() {
        // TBD;
    }
    
    // MARK: - Navigation
    private func showTemplatesPicker() {
        templatesCoordinator.showTemplatesPicker(
            data: TemplatePickerViewModelData(mode: .typeTemplate, typeId: document.objectId, spaceId: document.spaceId),
            onSetAsDefaultTempalte: { [weak self] templateId in
                // TBD;
            }
        )
    }
    
}
