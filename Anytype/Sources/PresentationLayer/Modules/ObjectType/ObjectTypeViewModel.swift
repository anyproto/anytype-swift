import SwiftUI
import Services

struct ObjectTypeViewModelState: Equatable {
    var title = ""
    var icon: ObjectIcon?
    
    var templates = [TemplatePreviewViewModel]()
    var syncStatusData: SyncStatusData?
    
    var showSyncStatusInfo = false
}


@MainActor
final class ObjectTypeViewModel: ObservableObject {
    @Published var state = ObjectTypeViewModelState()
    
    let data: EditorTypeObject
    
    private let document: any BaseDocumentProtocol
    
    private var isTemplatesEditable = false
    private var defaultTemplateId: String?
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
        case .installed:
            let index = state.templates.map { $0.model}.firstIndex(of: model) ?? 0
            showTemplatesPicker(index: index)
        case .blank:
            showTemplatesPicker(index: 0)
        case .addTemplate:
            onAddTemplateTap()
        }
    }
    
    func onSyncStatusTap() {
        state.showSyncStatusInfo.toggle()
    }
    
    // MARK: - Private
    func subscribeOnDetails() async {
        for await details in document.detailsPublisher.values {
            state.title = details.title
            state.icon = details.objectIcon
            
            if defaultTemplateId != details.defaultTemplateId {
                defaultTemplateId = details.defaultTemplateId
                updateTemplates()
            }
            
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
            state.syncStatusData = SyncStatusData(status: status.syncStatus, networkId: accountManager.account.info.networkId, isHidden: false)
        }
    }
    
    // Adding ephemeral Blank template
    private func updateTemplates() {
        let middlewareTemplates = rawTemplates.map {
            let decoration: TemplateDecoration? = ($0.id == defaultTemplateId) ? .defaultBadge : nil
            return TemplatePreviewModel(objectDetails: $0, decoration: decoration)
        }
        var templates = [TemplatePreviewModel]()
        
        let isBlankTemplateDefault = !middlewareTemplates.contains { $0.decoration != nil }
        templates.append(TemplatePreviewModel(
            mode: .blank,
            alignment: .left,
            decoration: isBlankTemplateDefault ? .defaultBadge : nil
        ))
        
        templates += middlewareTemplates

        if isTemplatesEditable {
            templates.append(.init(mode: .addTemplate, alignment: .center))
        }
        
        self.state.templates = templates.map { model in
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
    private func showTemplatesPicker(index: Int) {
        let data = TemplatePickerViewModelData(
            mode: .typeTemplate,
            typeId: document.objectId,
            spaceId: document.spaceId,
            defaultIndex: index
        )
        templatesCoordinator.showTemplatesPicker(
            data: data,
            onSetAsDefaultTempalte: { [weak self] templateId in
                // TBD;
            }
        )
    }
    
}
