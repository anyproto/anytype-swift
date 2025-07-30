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
    func onObjectTypesSearchAction(setDocument: some SetDocumentProtocol, completion: @escaping (ObjectType) -> Void)
    func templateEditingHandler(
        setting: ObjectCreationSetting,
        onSetAsDefaultTempalte: @escaping (String) -> Void,
        onTemplateSelection: ((ObjectCreationSetting) -> Void)?
    )
}

@MainActor
final class SetObjectCreationSettingsViewModel: ObservableObject {
    @Published var isEditingState = false
    @Published var objectTypes = [InstalledObjectTypeViewModel]()
    @Published var templates = [TemplatePreviewViewModel]()
    @Published var canChangeObjectType = false
    @Published var toastData: ToastBarData?
    
    var isTemplatesEditable = false
    
    private var userTemplates = [TemplatePreviewModel]() {
        didSet {
            updateTemplatesList()
        }
    }
    
    @Injected(\.templatesService)
    private var templatesService: any TemplatesServiceProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    
    private let interactor: any SetObjectCreationSettingsInteractorProtocol
    private let data: SetObjectCreationData
    
    private weak var output: (any SetObjectCreationSettingsOutput)?
    
    private var cancellables = [AnyCancellable]()
    
    init(
        interactor: some SetObjectCreationSettingsInteractorProtocol,
        data: SetObjectCreationData,
        output: (any SetObjectCreationSettingsOutput)?
    ) {
        self.interactor = interactor
        self.data = data
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
                route: data.setDocument.isCollection() ? .collection : .set
            )
        case .addTemplate:
            onAddTemplateTap()
        }
    }
    
    func onTemplateSelect(objectTypeId: String, templateId: String) {
        setTemplateAsDefault(templateId: templateId)
        data.onTemplateSelection(
            ObjectCreationSetting(
                objectTypeId: objectTypeId,
                spaceId: data.setDocument.spaceId,
                templateId: templateId
            )
        )
    }
    
    func onAddTemplateTap() {
        let objectTypeId = interactor.objectTypeId
        let spaceId = data.setDocument.spaceId
        Task { [weak self] in
            guard let self else { return }
            do {
                let templateId = try await templatesService.createTemplateFromObjectType(objectTypeId: objectTypeId, spaceId: spaceId)
                AnytypeAnalytics.instance().logTemplateCreate(objectType: .object(typeId: objectTypeId), spaceId: spaceId)
                output?.templateEditingHandler(
                    setting: ObjectCreationSetting(objectTypeId: objectTypeId, spaceId: spaceId, templateId: templateId),
                    onSetAsDefaultTempalte: { [weak self] templateId in
                        self?.setTemplateAsDefault(templateId: templateId)
                    },
                    onTemplateSelection: data.onTemplateSelection
                )
                let objectDetails = await retrieveObjectDetails(objectId: objectTypeId, spaceId: spaceId)
                let title = objectDetails?.title.trimmed(numberOfCharacters: 16) ?? ""
                toastData = ToastBarData(Loc.Templates.Popup.WasAddedTo.title(title))
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
                toastData = ToastBarData(Loc.Templates.Popup.default)
            }
        }
    }
    
    private func setObjectTypeAsDefault(objectType: ObjectType) {
        Task {
            do {
                try await interactor.setDefaultObjectType(objectTypeId: objectType.id)
                AnytypeAnalytics.instance().logDefaultObjectTypeChange(
                    objectType.analyticsType,
                    route: data.setDocument.isCollection() ? .collection : .set
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
            let isAvailable = defaultObjectType?.recommendedLayout?.isEditorLayout ?? false
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
            
            return InstalledObjectTypeViewModel(
                id: type.id,
                icon: .object(type.icon),
                title: type.displayName,
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
                output?.onObjectTypesSearchAction(setDocument: data.setDocument) { [weak self] objectType in
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
        let spaceId = data.setDocument.spaceId
        Task {
            do {
                switch option {
                case .delete:
                    try await templatesService.deleteTemplate(templateId: templateViewModel.id)
                    toastData = ToastBarData(Loc.Templates.Popup.removed)
                case .duplicate:
                    try await templatesService.cloneTemplate(blockId: templateViewModel.id)
                    toastData = ToastBarData(Loc.Templates.Popup.duplicated)
                case .editTemplate:
                    output?.templateEditingHandler(
                        setting: ObjectCreationSetting(objectTypeId: objectTypeId, spaceId: spaceId, templateId: templateViewModel.id),
                        onSetAsDefaultTempalte: { [weak self] templateId in
                            self?.setTemplateAsDefault(templateId: templateId)
                        },
                        onTemplateSelection: data.onTemplateSelection
                    )
                case .toggleIsDefault:
                    anytypeAssertionFailure("Unsupported action for lists: toggleIsDefault")
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
            AnytypeAnalytics.instance().logTemplateEditing(objectType: objectType, route: data.setDocument.isCollection() ? .collection : .set)
        case .delete:
            AnytypeAnalytics.instance().logMoveToBin(true)
        case .duplicate:
            AnytypeAnalytics.instance().logTemplateDuplicate(objectType: objectType, route: data.setDocument.isCollection() ? .collection : .set)
        case .toggleIsDefault:
            anytypeAssertionFailure("Unsupported action for lists: toggleIsDefault")
        }
    }
    
    private func updateTemplatesList() {
        var templates = [TemplatePreviewModel]()

        templates.append(contentsOf: userTemplates)
        if isTemplatesEditable {
            templates.append(TemplatePreviewModel(mode: .addTemplate, context: .list, alignment: .center))
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
    
    private func retrieveObjectDetails(objectId: String, spaceId: String) async -> ObjectDetails? {
        let targetDocument = documentsProvider.document(objectId: objectId, spaceId: spaceId, mode: .preview)
        try? await targetDocument.open()
        
        return targetDocument.details
    }
}

extension TemplatePreviewModel {
    init(
        objectDetails: ObjectDetails,
        context: TemplatePreviewContext,
        isDefault: Bool,
        decoration: TemplateDecoration?
    ) {
        self = TemplatePreviewModel(
            mode: .installed(.init(
                id: objectDetails.id,
                title: objectDetails.title,
                header: HeaderBuilder.buildObjectHeader(
                    details: objectDetails,
                    usecase: .templatePreview,
                    presentationUsecase: .full,
                    showPublishingBanner: false,
                    onIconTap: {},
                    onCoverTap: {}
                ),
                isBundled: objectDetails.templateIsBundled,
                isDefault: isDefault,
                style: objectDetails.resolvedLayoutValue == .todo ? .todo(objectDetails.isDone) : .none
            )
            ),
            context: context,
            alignment: objectDetails.layoutAlignValue,
            decoration: decoration
        )
    }
}

extension TemplatePreviewModel {
    var isEditable: Bool {
        contextualMenuOptions.isNotEmpty
    }
}
