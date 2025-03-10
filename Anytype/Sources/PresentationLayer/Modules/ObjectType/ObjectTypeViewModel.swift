import SwiftUI
import Services
import AnytypeCore
@preconcurrency import Combine

@MainActor
final class ObjectTypeViewModel: ObservableObject {
    @Published var details: ObjectDetails?
    
    @Published var templates = [TemplatePreviewViewModel]()
    @Published var templatesCount = 0
    @Published var syncStatusData: SyncStatusData?
    
    @Published var typeName = ""
    @Published var relationsCount: Int = 0
    
    @Published var toastBarData: ToastBarData = .empty
    @Published var showDeleteConfirmation = false
    @Published var showTemplates = false
    
    let document: any BaseDocumentProtocol
    var canEditDetails: Bool { document.permissions.canEditDetails }
    var isEditorLayout: Bool { document.details?.recommendedLayoutValue.isEditorLayout ?? false }
    var canArchive: Bool { document.permissions.canArchive }
    private(set) weak var output: (any ObjectTypeViewModelOutput)?
    
    private var defaultTemplateId: String? { details?.defaultTemplateId }
    private var rawTemplates: [ObjectDetails] = []
    private var didInitialSetup = false
    
    @Injected(\.templatesSubscription)
    private var templatesSubscription: any TemplatesSubscriptionServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.templatesService)
    private var templatesService: any TemplatesServiceProtocol
    @Injected(\.detailsService)
    private var detailsService: any DetailsServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    
    private var nameChangeTask: Task<(), any Error>?
    private var dismiss: DismissAction?
    
    init(document: any BaseDocumentProtocol, output: any ObjectTypeViewModelOutput) {
        self.output = output
        self.document = document
    }
    
    func setupSubscriptions() async {
        async let detailsSubscription: () = subscribeOnDetails()
        async let templatesSubscription: () = subscribeOnTemplates()
        async let syncStatusSubscription: () = subscribeOnSyncStatus()
        async let relationsSubscription: () = subscribeOnRelations()
        
        (_, _, _, _) = await (detailsSubscription, templatesSubscription, syncStatusSubscription, relationsSubscription)
    }
    
    func setDismissHandler(dismiss: DismissAction) {
        self.dismiss = dismiss
    }
    
    func onTemplateTap(model: TemplatePreviewModel) {
        switch model.mode {
        case .installed:
            output?.showTemplatesPicker(defaultTemplateId: model.mode.id)
        case .addTemplate:
            onAddTemplateTap()
        }
    }
    
    func onSyncStatusTap() {
        output?.onSyncStatusTap()
    }
    
    func onIconTap() {
        output?.onIconTap()
    }
    
    func onLayoutTap() {
        output?.onLayoutTap()
    }
    
    func onFieldsTap() {
        output?.onFieldsTap()
    }
    
    func onTypeNameChange(name: String) {
        nameChangeTask?.cancel()
        nameChangeTask = Task {
            try await Task.sleep(seconds: 0.5)
            try await detailsService.updateBundledDetails(objectId: document.objectId, bundledDetails: [.name(name)])
            
            if name != details?.objectName {
                AnytypeAnalytics.instance().logSetObjectTitle(objectType: document.details?.analyticsType)
            }
        }
    }
    
    func onDeleteTap() {
        showDeleteConfirmation.toggle()
    }
    
    func onDeleteConfirm() async throws {
        try await objectActionsService.delete(objectIds: [document.objectId])
        showDeleteConfirmation = false
        dismiss?()
    }
    
    // MARK: - Private
    func subscribeOnDetails() async {
        for await details in document.detailsPublisher.values {
            if !didInitialSetup {
                typeName = details.objectName
                AnytypeAnalytics.instance().logScreenType(objectType: details.analyticsType)
                didInitialSetup = true
            }
            
            self.details = details
            
            if let recommendedLayout = details.recommendedLayoutValue {
                let isSupportedLayout = recommendedLayout.isEditorLayout
                let isTemplate = details.isTemplateType
                showTemplates = isSupportedLayout && !isTemplate
                if showTemplates { buildTemplates() }
            } else {
                showTemplates = false
            }
        }
    }
    
    func subscribeOnTemplates() async {
        let publisher = await templatesSubscription.startSubscription(objectType: document.objectId, spaceId: document.spaceId, update: nil)
        for await rawTemplates in publisher.values {
            self.rawTemplates = rawTemplates
            buildTemplates()
        }
    }
    
    func subscribeOnSyncStatus() async {
        for await status in document.syncStatusDataPublisher.values {
            withAnimation {
                syncStatusData = SyncStatusData(status: status.syncStatus, networkId: accountManager.account.info.networkId, isHidden: false)
            }
        }
    }
    
    func subscribeOnRelations() async {
        for await relations in document.parsedRelationsPublisherForType.values {
            let conflictingKeys = (try? await relationsService
                .getConflictRelationsForType(typeId: document.objectId, spaceId: document.spaceId)) ?? []
            let conflictingRelations = relationDetailsStorage
                .relationsDetails(ids: conflictingKeys, spaceId: document.spaceId)
                .filter { !$0.isHidden && !$0.isDeleted }
                .filter { $0.key != BundledRelationKey.description.rawValue }

            self.relationsCount = relations.installed.count + conflictingRelations.count
        }
    }
    
    // Adding ephemeral Blank template and create new template button
    private func buildTemplates() {
        var templates = [TemplatePreviewModel]()
        
        let middlewareTemplates = rawTemplates.map { details in
            let isDefault = details.id == defaultTemplateId
            let decoration: TemplateDecoration? = isDefault ? .defaultBadge : nil
            return TemplatePreviewModel(objectDetails: details, decoration: decoration)
        }
        
        templates += middlewareTemplates
        templatesCount = middlewareTemplates.count

        if canEditDetails {
            templates.append(.init(mode: .addTemplate, alignment: .center))
        }
        
        self.templates = templates.map { model in
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
                let templateId = try await templatesService.createTemplateFromObjectType(objectTypeId: document.objectId, spaceId: document.spaceId)
                output?.showTemplatesPicker(defaultTemplateId: templateId)
                toastBarData = ToastBarData(text: Loc.Templates.Popup.WasAddedTo.title(details?.title ?? ""), showSnackBar: true)
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
}
