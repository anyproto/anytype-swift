import SwiftUI
import Services


@MainActor
final class ObjectTypeViewModel: ObservableObject {
    @Published var title = ""
    @Published var templates = [TemplatePreviewViewModel]()
    
    private let data: EditorTypeObject
    private let document: any BaseDocumentProtocol
    
    @Injected(\.templatesSubscription)
    private var templatesSubscription: any TemplatesSubscriptionServiceProtocol
    
    init(data: EditorTypeObject) {
        self.data = data
        self.document = Container.shared.documentService().document(objectId: data.objectId, spaceId: data.spaceId)
    }
    
    func setupSubscriptions() async {
        async let detailsSubscription: () = subscribeOnDetails()
        async let templatesSubscription: () = subscribeOnTemplates()
        (_, _) = await (detailsSubscription, templatesSubscription)
    }
    
    func onTemplateTap(model: TemplatePreviewModel) {
        // TBD;
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
    
    private func updateTemplates(detailsList: [ObjectDetails]) {
        let middlewareTemplates = detailsList.map { TemplatePreviewModel(objectDetails: $0, isDefault: false) } // TBD: isDefault
        var templates = [TemplatePreviewModel]()
        
        let isBlankTemplateDefault = !middlewareTemplates.contains { $0.isDefault }
        templates.append(TemplatePreviewModel(mode: .blank, alignment: .left, isDefault: isBlankTemplateDefault))
        
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
