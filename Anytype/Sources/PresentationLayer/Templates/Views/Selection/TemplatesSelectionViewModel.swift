import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI

@MainActor
final class TemplatesSelectionViewModel: ObservableObject {
    @Published var isEditingState = false
    @Published var templates = [TemplatePreviewViewModel]()
    
    private var userTemplates = [TemplatePreviewModel]() {
        didSet {
            updateTemplatesList()
        }
    }
    
    private let interactor: TemplateSelectionInteractorProvider
    private let setDocument: SetDocumentProtocol
    private let templatesService: TemplatesServiceProtocol
    private let onTemplateSelection: (BlockId?) -> Void
    private let templateEditingHandler: ((BlockId) -> Void)
    private var cancellables = [AnyCancellable]()
    
    init(
        interactor: TemplateSelectionInteractorProvider,
        setDocument: SetDocumentProtocol,
        templatesService: TemplatesServiceProtocol,
        onTemplateSelection: @escaping (BlockId?) -> Void,
        templateEditingHandler: @escaping ((BlockId) -> Void)
    ) {
        self.interactor = interactor
        self.setDocument = setDocument
        self.templatesService = templatesService
        self.onTemplateSelection = onTemplateSelection
        self.templateEditingHandler = templateEditingHandler
        
        updateTemplatesList()
        
        interactor.userTemplates.sink { [weak self] templates in
            if let userTemplates = self?.userTemplates,
                userTemplates != templates {
                self?.userTemplates = templates
            }
        }.store(in: &cancellables)
    }
    
    func onTemplateTap(model: TemplatePreviewModel) {
        switch model.mode {
        case .installed(let templateModel):
            onTemplateSelection(templateModel.id)
            AnytypeAnalytics.instance().logTemplateSelection(
                objectType: templateModel.isBundled ? .object(typeId: templateModel.id) : .custom,
                route: setDocument.isCollection() ? .collection : .set
            )
        case .blank:
            onTemplateSelection(nil)
            AnytypeAnalytics.instance().logTemplateSelection(
                objectType: nil,
                route: setDocument.isCollection() ? .collection : .set
            )
        case .addTemplate:
            onAddTemplateTap()
        }
    }
    
    func onAddTemplateTap() {
        let objectTypeId = interactor.objectTypeId.rawValue
        Task { [weak self] in
            do {
                guard let objectId = try await self?.templatesService.createTemplateFromObjectType(objectTypeId: objectTypeId) else {
                    return
                }
                AnytypeAnalytics.instance().logTemplateCreate(objectType: .object(typeId: objectTypeId))
                self?.templateEditingHandler(objectId)
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
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
                    templateEditingHandler(templateViewModel.id)
                case .setAsDefault:
                    try await interactor.setDefaultTemplate(model: templateViewModel)
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
            AnytypeAnalytics.instance().logTemplateEditing(objectType: objectType, route: setDocument.isCollection() ? .collection : .set)
        case .delete:
            AnytypeAnalytics.instance().logMoveToBin(true)
        case .duplicate:
            AnytypeAnalytics.instance().logTemplateDuplicate(objectType: objectType, route: setDocument.isCollection() ? .collection : .set)
        case .setAsDefault:
            break // Interactor resposibility
        }
    }
    
    private func updateTemplatesList() {
        var templates = [TemplatePreviewModel]()

        if !userTemplates.contains(where: { $0.isDefault }) {
            templates.append(.init(mode: .blank, alignment: .left, isDefault: true))
        } else {
            templates.append(.init(mode: .blank, alignment: .left, isDefault: false))
        }
        
        templates.append(contentsOf: userTemplates)
        templates.append(.init(mode: .addTemplate, alignment: .center, isDefault: false))
        
        withAnimation {
            self.templates = templates.map { model in
                TemplatePreviewViewModel(
                    model: model,
                    onOptionSelection: { [weak self] option in
                        self?.handleTemplateOption(option: option, templateViewModel: model)
                    }
                )
            }
        }
    }
}

extension TemplatePreviewModel {
    init(objectDetails: ObjectDetails, isDefault: Bool) {
        self = .init(
            mode: .installed(.init(
                id: objectDetails.id,
                title: objectDetails.title,
                header: HeaderBuilder.buildObjectHeader(
                    details: objectDetails,
                    usecase: .templatePreview,
                    onIconTap: {},
                    onCoverTap: {}
                ),
                isBundled: objectDetails.templateIsBundled,
                style: objectDetails.layoutValue == .todo ? .todo(false) : .none
            )
            ),
            alignment: objectDetails.layoutAlignValue,
            isDefault: isDefault
        )
    }
}

extension TemplatePreviewModel {
    var isEditable: Bool {
        if case .installed = mode {
            return true
        }
        
        return false
    }
}
