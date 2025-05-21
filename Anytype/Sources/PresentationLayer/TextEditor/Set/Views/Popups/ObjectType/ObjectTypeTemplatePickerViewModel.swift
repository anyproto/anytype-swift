import SwiftUI
import Services
import AnytypeCore
import AsyncAlgorithms
@preconcurrency import Combine

@MainActor
final class ObjectTypeTemplatePickerViewModel: ObservableObject {
    @Published var templates = [TemplatePreviewViewModel]()
    @Published var templatesCount = 0
    @Published var toastBarData: ToastBarData?
    @Published var isEditing = false
    
    private var output: (any EditorSetModuleOutput)?
    private let document: any BaseDocumentProtocol
    private var loggedOnAppear = false
    
    @Injected(\.templatesService)
    private var templatesService: any TemplatesServiceProtocol
    @Injected(\.templatesSubscription)
    private var templatesSubscription: any TemplatesSubscriptionServiceProtocol
    
    init(document: any BaseDocumentProtocol, output: any EditorSetModuleOutput) {
        self.document = document
        self.output = output
    }
    
    func onAppear() {
        if !loggedOnAppear {
            AnytypeAnalytics.instance().logScreenTypeTemplateSelector()
            loggedOnAppear = true
        }
    }
    
    func setupSubscriptions() async {
        async let subscription: () = subscribe()
        
        (_) = await (subscription)
    }
    
    func onTemplateTap(model: TemplatePreviewModel) {
        switch model.mode {
        case .installed:
            output?.onObjectTypeSingleTemplateTap(objectId: document.objectId, spaceId: document.spaceId, defaultTemplateId: model.mode.id)
        case .addTemplate:
            onAddTemplateTap()
        }
    }
    
    func onAddTemplateTap() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let templateId = try await templatesService.createTemplateFromObjectType(objectTypeId: document.objectId, spaceId: document.spaceId)
                output?.onObjectTypeSingleTemplateTap(objectId: document.objectId, spaceId: document.spaceId, defaultTemplateId: templateId)
                toastBarData = ToastBarData(Loc.Templates.Popup.WasAddedTo.title(document.details?.title ?? ""))
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    func onEditTap() {
        withAnimation(.snappy) { isEditing.toggle() }
    }
    
    // MARK: - Private
    private func subscribe() async {
        let detailsPublisher = document.detailsPublisher
        let templatesPublisher = await templatesSubscription.startSubscription(objectType: document.objectId, spaceId: document.spaceId, update: nil)
        
        let combinedStream = combineLatest(detailsPublisher.values, templatesPublisher.values).throttle(milliseconds: 300)
        
        for await (details, rawTemplates) in combinedStream {
            buildTemplates(documentDetails: details, rawTemplates: rawTemplates)
        }
    }
    
    // Adding ephemeral Blank template and create new template button
    private func buildTemplates(documentDetails: ObjectDetails, rawTemplates: [ObjectDetails]) {
        var templates = [TemplatePreviewModel]()
        
        let middlewareTemplates = rawTemplates.map { details in
            let isDefault = details.id == documentDetails.defaultTemplateId
            let decoration: TemplateDecoration? = isDefault ? .defaultBadge : nil
            return TemplatePreviewModel(objectDetails: details, context: .type, isDefault: isDefault, decoration: decoration)
        }
        
        templates += middlewareTemplates
        templatesCount = middlewareTemplates.count

        if document.permissions.canEditDetails {
            templates.append(TemplatePreviewModel(mode: .addTemplate, context: .type, alignment: .center))
        }
        
        withAnimation(self.templates.isNotEmpty ? .snappy : nil) {
            self.templates = templates.map { model in
                TemplatePreviewViewModel(
                    model: model,
                    onOptionSelection: { [weak self] in
                        self?.handleTemplateOption(option: $0, templateViewModel: model)
                    }
                )
            }
        }
    }
    
    private func handleTemplateOption(
        option: TemplateOptionAction,
        templateViewModel: TemplatePreviewModel
    ) {
        Task {
            do {
                switch option {
                case .delete:
                    try await templatesService.deleteTemplate(templateId: templateViewModel.id)
                    toastBarData = ToastBarData(Loc.Templates.Popup.removed)
                case .duplicate:
                    try await templatesService.cloneTemplate(blockId: templateViewModel.id)
                    toastBarData = ToastBarData(Loc.Templates.Popup.duplicated)
                case .editTemplate:
                    anytypeAssertionFailure("Unsupported action .editTemplate")
                case .toggleIsDefault(let isDefault):
                    if isDefault {
                        try await templatesService.setTemplateAsDefaultForType(objectTypeId: document.objectId, templateId: "")
                    } else {
                        try await templatesService.setTemplateAsDefaultForType(objectTypeId: document.objectId, templateId: templateViewModel.id)
                    }
                }
                
                handleAnalytics(option: option, templateViewModel: templateViewModel)
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    private func handleAnalytics(option: TemplateOptionAction, templateViewModel: TemplatePreviewModel) {
        guard case let .installed(templateModel) = templateViewModel.mode else {
            return
        }
        
        let objectType: AnalyticsObjectType = templateModel.isBundled ? .object(typeId: templateModel.id) : .custom
        
        switch option {
        case .editTemplate:
            AnytypeAnalytics.instance().logTemplateEditing(objectType: objectType, route: .type)
        case .delete:
            AnytypeAnalytics.instance().logMoveToBin(true)
        case .duplicate:
            AnytypeAnalytics.instance().logTemplateDuplicate(objectType: objectType, route: .type)
        case .toggleIsDefault(let isDefault):
            AnytypeAnalytics.instance().logChangeDefaultTemplate(objectType: objectType, route: .type)
        }
    }
}
