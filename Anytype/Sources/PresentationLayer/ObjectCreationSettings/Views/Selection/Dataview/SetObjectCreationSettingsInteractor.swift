import Combine
import Services
import AnytypeCore

protocol SetObjectCreationSettingsInteractorProtocol {
    var mode: SetObjectCreationSettingsMode { get }
    
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> { get }
    
    var objectTypesAvailabilityPublisher: AnyPublisher<Bool, Never> { get }
    var objectTypeId: ObjectTypeId { get }
    var objectTypesConfigPublisher: AnyPublisher<ObjectTypesConfiguration, Never> { get }
    func setObjectTypeId(_ objectTypeId: ObjectTypeId)
    
    func setDefaultObjectType(objectTypeId: BlockId) async throws
    func setDefaultTemplate(templateId: BlockId) async throws
}

final class SetObjectCreationSettingsInteractor: SetObjectCreationSettingsInteractorProtocol {
    
    var objectTypesAvailabilityPublisher: AnyPublisher<Bool, Never> { $canChangeObjectType.eraseToAnyPublisher() }
    
    var objectTypesConfigPublisher: AnyPublisher<ObjectTypesConfiguration, Never> {
        Publishers.CombineLatest(installedObjectTypesProvider.objectTypesPublisher, $objectTypeId)
            .map { objectTypes, objectTypeId in
                return ObjectTypesConfiguration(
                    objectTypes: objectTypes,
                    objectTypeId: objectTypeId
                )
            }
            .eraseToAnyPublisher()
    }
    
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> {
        Publishers.CombineLatest3($templatesDetails, $defaultTemplateId, $typeDefaultTemplateId)
            .map { details, defaultTemplateId, typeDefaultTemplateId in
                let templateId = defaultTemplateId.isNotEmpty ? defaultTemplateId : typeDefaultTemplateId
                return details.map {
                    TemplatePreviewModel(
                        objectDetails: $0,
                        isDefault: $0.id == templateId
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    @Published var objectTypeId: ObjectTypeId
    @Published var canChangeObjectType = false
    
    let mode: SetObjectCreationSettingsMode
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    
    private let subscriptionService: TemplatesSubscriptionServiceProtocol
    private let installedObjectTypesProvider: InstalledObjectTypesProviderProtocol
    private let dataviewService: DataviewServiceProtocol
    
    @Published private var templatesDetails = [ObjectDetails]()
    @Published private var defaultTemplateId: BlockId
    @Published private var typeDefaultTemplateId: BlockId = .empty
    
    private var dataView: DataviewView
    
    private var cancellables = [AnyCancellable]()
    
    init(
        mode: SetObjectCreationSettingsMode,
        setDocument: SetDocumentProtocol,
        viewId: String,
        installedObjectTypesProvider: InstalledObjectTypesProviderProtocol,
        subscriptionService: TemplatesSubscriptionServiceProtocol,
        dataviewService: DataviewServiceProtocol
    ) {
        self.mode = mode
        self.setDocument = setDocument
        self.viewId = viewId
        self.dataView = setDocument.view(by: viewId)
        self.defaultTemplateId = dataView.defaultTemplateID ?? .empty
        self.subscriptionService = subscriptionService
        self.installedObjectTypesProvider = installedObjectTypesProvider
        self.dataviewService = dataviewService
        
        let defaultObjectTypeID = dataView.defaultObjectTypeIDWithFallback
        if setDocument.isTypeSet() {
            if let firstSetOf = setDocument.details?.setOf.first {
                self.objectTypeId = .dynamic(firstSetOf)
            } else {
                self.objectTypeId = .dynamic(defaultObjectTypeID)
                anytypeAssertionFailure("Couldn't find default object type in sets", info: ["setId": setDocument.objectId])
            }
        } else {
            self.objectTypeId = .dynamic(defaultObjectTypeID)
        }
        
        subscribeOnDocmentUpdates()
        loadTemplates()
    }
    
    func setObjectTypeId(_ objectTypeId: ObjectTypeId) {
        self.objectTypeId = objectTypeId
        loadTemplates()
    }
    
    func setDefaultObjectType(objectTypeId: BlockId) async throws {
        let updatedDataView = dataView.updated(defaultObjectTypeID: objectTypeId)
        try await dataviewService.updateView(updatedDataView)
    }
    
    func setDefaultTemplate(templateId: BlockId) async throws {
        let updatedDataView = dataView.updated(defaultTemplateID: templateId)
        try await dataviewService.updateView(updatedDataView)
    }
    
    private func subscribeOnDocmentUpdates() {
        setDocument.syncPublisher.sink { [weak self] in
            guard let self else { return }
            dataView = setDocument.view(by: dataView.id)
            if defaultTemplateId != dataView.defaultTemplateID {
                defaultTemplateId = dataView.defaultTemplateID ?? .empty
            }
            
            guard mode == .default else { return }
            
            if !setDocument.isTypeSet(), objectTypeId.rawValue != dataView.defaultObjectTypeIDWithFallback {
                objectTypeId = .dynamic(dataView.defaultObjectTypeIDWithFallback)
                loadTemplates()
            }
        }.store(in: &cancellables)
        
        setDocument.detailsPublisher.sink { [weak self] details in
            guard let self else { return }
            let isNotTypeSet = !setDocument.isTypeSet()
            if canChangeObjectType != isNotTypeSet {
                canChangeObjectType = isNotTypeSet
            }
        }
        .store(in: &cancellables)
    
        startObjectTypesSubscription()
        installedObjectTypesProvider.objectTypesPublisher.sink { [weak self] objectTypes in
            guard let self else { return }
            let defaultTemplateId = objectTypes.first { [weak self] in
                guard let self else { return false }
                return $0.id == objectTypeId.rawValue
            }?.defaultTemplateId ?? .empty
            if typeDefaultTemplateId != defaultTemplateId {
                typeDefaultTemplateId = defaultTemplateId
            }
        }.store(in: &cancellables)
    }
    
    private func startObjectTypesSubscription() {
        Task { [weak self] in
            guard let self else { return }
            await installedObjectTypesProvider.startSubscription()
        }
    }
    
    private func loadTemplates() {
        subscriptionService.startSubscription(objectType: objectTypeId) { [weak self] _, update in
            self?.templatesDetails.applySubscriptionUpdate(update)
        }
    }
}
