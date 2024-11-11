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
    
    @Injected(\.templatesSubscription)
    private var templatesSubscription: any TemplatesSubscriptionServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
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
        // TBD;
    }
    
    func onSyncStatusTap() {
        showSyncStatusInfo.toggle()
    }
    
    // MARK: - Private
    func subscribeOnDetails() async {
        for await details in document.detailsPublisher.values {
            title = details.title
        }
    }
    
    func subscribeOnTemplates() async {
        await templatesSubscription.startSubscription(objectType: data.objectId, spaceId: data.spaceId) { [weak self] detailsList in
            guard let self else { return }
            updateTemplates(detailsList: detailsList)
        }
    }
    
    func subscribeOnSyncStatus() async {
        for await status in document.syncStatusDataPublisher.values {
            syncStatusData = SyncStatusData(status: status.syncStatus, networkId: accountManager.account.info.networkId, isHidden: false)
        }
    }
    
    // Adding ephemeral Blank template
    private func updateTemplates(detailsList: [ObjectDetails]) {
        let middlewareTemplates = detailsList.map { TemplatePreviewModel(objectDetails: $0, decoration: nil) } // TBD: isDefault
        var templates = [TemplatePreviewModel]()
        
//        let isBlankTemplateDefault = !middlewareTemplates.contains { $0.isDefault }
        templates.append(TemplatePreviewModel(mode: .blank, alignment: .left, decoration: .defaultBadge))
        
        templates += middlewareTemplates

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
}
