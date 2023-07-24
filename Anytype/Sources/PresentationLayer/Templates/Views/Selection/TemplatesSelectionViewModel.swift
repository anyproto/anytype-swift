import Foundation
import AnytypeCore
import Services
import Combine

@MainActor
final class TemplatesSelectionViewModel: ObservableObject {
    @Published var isEditingState = false
    @Published var templates = [TemplatePreviewModel]()
    var templateOptionsHandler: ((@escaping (TemplateOptionAction) -> Void) -> Void)?
    
    private var userTemplates = [TemplatePreviewModel]() {
        didSet {
            updateTemplatesList()
        }
    }
    private let interactor: TemplateSelectionInteractorProvider
    private let templatesService: TemplatesServiceProtocol
    private let onTemplateSelection: (BlockId) -> Void
    private var cancellables = [AnyCancellable]()
    
    init(
        interactor: TemplateSelectionInteractorProvider,
        templatesService: TemplatesServiceProtocol,
        onTemplateSelection: @escaping (BlockId) -> Void
    ) {
        self.interactor = interactor
        self.templatesService = templatesService
        self.onTemplateSelection = onTemplateSelection
        
        interactor.userTemplates.sink { [weak self] templates in
            self?.userTemplates = templates
        }.store(in: &cancellables)
    }
    
    func onModelTap(model: TemplatePreviewModel) {
        onTemplateSelection(model.id)
    }
    
    func onEditingButonTap(model: TemplatePreviewModel) {
        templateOptionsHandler? { [weak self] option in
            self?.handleTemplateOption(option: option, templateViewModel: model)
        }
    }
    
    private func handleTemplateOption(option: TemplateOptionAction, templateViewModel: TemplatePreviewModel) {
        Task {
            do {
                switch option {
                case .delete:
                    try await templatesService.deleteTemplate(templateId: templateViewModel.id)
                case .duplicate:
                    try await templatesService.cloneTemplate(blockId: templateViewModel.id)
                case .editTemplate:
                    fatalError()
                case .setAsDefault:
                    try await interactor.setDefaultTemplate(model: templateViewModel)
                }
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    private func updateTemplatesList() {
        var templates = [TemplatePreviewModel]()

        if !userTemplates.contains(where: { $0.isDefault }) {
            templates.append(.init(model: .blank, alignment: .left, isDefault: true))
        } else {
            templates.append(.init(model: .blank, alignment: .left, isDefault: false))
        }
        
        
        templates.append(contentsOf: userTemplates)

        self.templates = templates
    }
}

extension TemplatePreviewModel {
    init(objectDetails: ObjectDetails, isDefault: Bool) {
        self = .init(
            model: .installed(.init(
                id: objectDetails.id,
                title: objectDetails.title,
                header: HeaderBuilder.buildObjectHeader(
                    details: objectDetails,
                    usecase: .templatePreview,
                    onIconTap: {},
                    onCoverTap: {}
                )
            )
            ),
            alignment: objectDetails.layoutAlignValue,
            isDefault: isDefault
        )
    }
}

extension TemplatePreviewModel {
    var isEditable: Bool {
        if case .blank = model {
            return false
        }
        
        return true
    }
}
