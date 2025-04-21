import SwiftUI
import Services
import AnytypeCore
@preconcurrency import Combine

@MainActor
final class ObjectTypeTemplatePickerViewModel: ObservableObject {
    @Published var templates = [TemplatePreviewViewModel]()
    @Published var templatesCount = 0
    @Published var toastBarData = ToastBarData.empty
    
    private var output: (any EditorSetModuleOutput)?
    private let document: any BaseDocumentProtocol
    
    @Injected(\.templatesService)
    private var templatesService: any TemplatesServiceProtocol
    @Injected(\.templatesSubscription)
    private var templatesSubscription: any TemplatesSubscriptionServiceProtocol
    
    init(document: any BaseDocumentProtocol, output: any EditorSetModuleOutput) {
        self.document = document
        self.output = output
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
                toastBarData = ToastBarData(text: Loc.Templates.Popup.WasAddedTo.title(document.details?.title ?? ""), showSnackBar: true)
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private
    private func subscribe() async {
        buildTemplates([])
        let publisher = await templatesSubscription.startSubscription(objectType: document.objectId, spaceId: document.spaceId, update: nil)
        for await rawTemplates in publisher.values {
            buildTemplates(rawTemplates)
        }
    }
    
    // Adding ephemeral Blank template and create new template button
    private func buildTemplates(_ rawTemplates: [ObjectDetails]) {
        var templates = [TemplatePreviewModel]()
        
        let middlewareTemplates = rawTemplates.map { details in
            let isDefault = details.id == document.details?.defaultTemplateId
            let decoration: TemplateDecoration? = isDefault ? .defaultBadge : nil
            return TemplatePreviewModel(objectDetails: details, decoration: decoration)
        }
        
        templates += middlewareTemplates
        templatesCount = middlewareTemplates.count

        if document.permissions.canEditDetails {
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
}
