import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI

struct ObjectCreationSetting {
    let objectTypeId: String
    let spaceId: String
    let templateId: String
}

@MainActor
protocol SetObjectCreationSettingsOutput: AnyObject {
    func onTemplateSelection(setting: ObjectCreationSetting)
    func onObjectTypesSearchAction(setDocument: SetDocumentProtocol, completion: @escaping (ObjectType) -> Void)
    func templateEditingHandler(
        setting: ObjectCreationSetting,
        onSetAsDefaultTempalte: @escaping (String) -> Void
    )
}

@MainActor
final class SetObjectCreationSettingsViewModel: ObservableObject {
    @Published var isEditingState = false
    @Published var objectTypes = [InstalledObjectTypeViewModel]()
    @Published var templates = [TemplatePreviewViewModel]()
    @Published var canChangeObjectType = false
    @Published var toastData: ToastBarData = .empty
    
    var isTemplatesEditable = false
    
    private var userTemplates = [TemplatePreviewModel]() {
        didSet {
            updateTemplatesList()
        }
    }
    
    @Injected(\.templatesService)
    private var templatesService: TemplatesServiceProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: DocumentsProviderProtocol
    
    private let interactor: SetObjectCreationSettingsInteractorProtocol
    private let setDocument: SetDocumentProtocol
    
    private weak var output: SetObjectCreationSettingsOutput?
    
    private var cancellables = [AnyCancellable]()
    
    init(
        interactor: SetObjectCreationSettingsInteractorProtocol,
        setDocument: SetDocumentProtocol,
        output: SetObjectCreationSettingsOutput?
    ) {
        self.interactor = interactor
        self.setDocument = setDocument
        self.output = output
        
        updateTemplatesList()
        
        setupSubscriptions()
    }
    
    func onTemplateTap(model: TemplatePreviewModel) {
        switch model.mode {
        case .installed(let templateModel):
            onTemplateSelect(
                objectTypeId: interactor.objectTypeId,
                templateId: templateModel.id
            )
            AnytypeAnalytics.instance().logChangeDefaultTemplate(
                objectType: templateModel.isBundled ? .object(typeId: templateModel.id) : .custom,
                route: setDocument.isCollection() ? .collection : .set
            )
        case .blank:
            onTemplateSelect(
                objectTypeId: interactor.objectTypeId,
                templateId: TemplateType.blank.id
            )
            AnytypeAnalytics.instance().logChangeDefaultTemplate(
                objectType: nil,
                route: setDocument.isCollection() ? .collection : .set
            )
        case .addTemplate:
            onAddTemplateTap()
        }
    }
    
    func onTemplateSelect(objectTypeId: String, templateId: String) {
        setTemplateAsDefault(templateId: templateId)
        output?.onTemplateSelection(
            setting: ObjectCreationSetting(
                objectTypeId: objectTypeId,
                spaceId: setDocument.spaceId,
                templateId: templateId
            )
        )
    }
    
    func onAddTemplateTap() {
        let objectTypeId = interactor.objectTypeId
        let spaceId = setDocument.spaceId
        Task { [weak self] in
            guard let self else { return }
            do {
                let templateId = try await templatesService.createTemplateFromObjectType(objectTypeId: objectTypeId)
                AnytypeAnalytics.instance().logTemplateCreate(objectType: .object(typeId: objectTypeId), spaceId: spaceId)
                output?.templateEditingHandler(
                    setting: ObjectCreationSetting(objectTypeId: objectTypeId, spaceId: spaceId, templateId: templateId),
                    onSetAsDefaultTempalte: { [weak self] templateId in
                        self?.setTemplateAsDefault(templateId: templateId)
                    }
                )
                let objectDetails = await retrieveObjectDetails(objectId: interactor.objectTypeId)
                let title = objectDetails?.title.trimmed(numberOfCharacters: 16) ?? ""
                toastData = ToastBarData(text: Loc.Templates.Popup.WasAddedTo.title(title), showSnackBar: true)
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    func setObjectType(_ objectType: ObjectType) {
        setObjectTypeAsDefault(objectType: objectType)
    }
    
    func setTemplateAsDefault(templateId: String) {
        Task {
            do {
                try await interactor.setDefaultTemplate(templateId: templateId)
            }
        }
    }
    
    func setTemplateAsDefaultForType(templateId: String) {
        Task {
            do {
                try await templatesService.setTemplateAsDefaultForType(objectTypeId: interactor.objectTypeId, templateId: templateId)
                toastData = ToastBarData(text: Loc.Templates.Popup.default, showSnackBar: true)
            }
        }
    }
    
    private func setObjectTypeAsDefault(objectType: ObjectType) {
        Task {
            do {
                try await interactor.setDefaultObjectType(objectTypeId: objectType.id)
                AnytypeAnalytics.instance().logDefaultObjectTypeChange(
                    objectType.analyticsType,
                    route: setDocument.isCollection() ? .collection : .set
                )
            }
        }
    }
    
    private func setupSubscriptions() {
        // Templates
        interactor.userTemplates.sink { [weak self] templates in
            if let userTemplates = self?.userTemplates,
                userTemplates != templates {
                self?.userTemplates = templates
            }
        }.store(in: &cancellables)
        
        // Object types
        interactor.objectTypesAvailabilityPublisher.sink { [weak self] canChangeObjectType in
            self?.canChangeObjectType = canChangeObjectType
        }.store(in: &cancellables)
        
        interactor.objectTypesConfigPublisher.sink { [weak self] objectTypesConfig in
            guard let self else { return }
            let defaultObjectType = objectTypesConfig.objectTypes.first {
                $0.id == objectTypesConfig.objectTypeId
            }
            let isAvailable = defaultObjectType?.recommendedLayout?.isTemplatesAvailable ?? false
            if isAvailable != isTemplatesEditable {
                isTemplatesEditable = isAvailable
                updateTemplatesList()
            }
            updateObjectTypes(objectTypesConfig)
        }.store(in: &cancellables)
    }
    
    private func updateObjectTypes(_ objectTypesConfig: ObjectTypesConfiguration) {
        var convertedObjectTypes = objectTypesConfig.objectTypes.map {  type in
            let isSelected = type.id == objectTypesConfig.objectTypeId
            let icon = type.iconEmoji.flatMap { 
                Icon.object(.emoji($0))
            }
            return InstalledObjectTypeViewModel(
                id: type.id,
                icon: icon,
                title: type.name,
                isSelected: isSelected,
                onTap: { [weak self] in
                    self?.setObjectType(type)
                }
            )
        }
        let searchItem = InstalledObjectTypeViewModel(
            id: InstalledObjectTypeViewModel.searchId,
            icon: .asset(.X18.search),
            title: nil,
            isSelected: false,
            onTap: { [weak self] in
                guard let self else { return }
                output?.onObjectTypesSearchAction(setDocument: setDocument) { [weak self] objectType in
                    self?.setObjectType(objectType)
                }
            }
        )
        convertedObjectTypes.insert(searchItem, at: 0)
        objectTypes = convertedObjectTypes
    }
    
    private func handleTemplateOption(
        option: TemplateOptionAction,
        templateViewModel: TemplatePreviewModel
    ) {
        let objectTypeId = interactor.objectTypeId
        let spaceId = setDocument.spaceId
        Task {
            do {
                switch option {
                case .delete:
                    try await templatesService.deleteTemplate(templateId: templateViewModel.id)
                    toastData = ToastBarData(text: Loc.Templates.Popup.removed, showSnackBar: true)
                case .duplicate:
                    try await templatesService.cloneTemplate(blockId: templateViewModel.id)
                    toastData = ToastBarData(text: Loc.Templates.Popup.duplicated, showSnackBar: true)
                case .editTemplate:
                    output?.templateEditingHandler(
                        setting: ObjectCreationSetting(objectTypeId: objectTypeId, spaceId: spaceId, templateId: templateViewModel.id),
                        onSetAsDefaultTempalte: { [weak self] templateId in
                            self?.setTemplateAsDefault(templateId: templateId)
                        }
                    )
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
        if isTemplatesEditable {
            templates.append(.init(mode: .addTemplate, alignment: .center, isDefault: false))
        }
        
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
    
    private func retrieveObjectDetails(objectId: String) async -> ObjectDetails? {
        let targetDocument = documentsProvider.document(objectId: objectId, forPreview: true)
        try? await targetDocument.openForPreview()
        
        return targetDocument.details
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
                    presentationUsecase: .editor,
                    onIconTap: {},
                    onCoverTap: {}
                ),
                isBundled: objectDetails.templateIsBundled,
                style: objectDetails.layoutValue == .todo ? .todo(objectDetails.isDone) : .none
            )
            ),
            alignment: objectDetails.layoutAlignValue,
            isDefault: isDefault
        )
    }
}

extension TemplatePreviewModel {
    var isEditable: Bool {
        contextualMenuOptions.isNotEmpty
    }
}
