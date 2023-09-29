import Combine
import Services
import AnytypeCore

protocol SetObjectCreationSettingsInteractorProtocol {
    var mode: SetObjectCreationSettingsMode { get }
    
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> { get }
    
    var objectTypesAvailabilityPublisher: AnyPublisher<Bool, Never> { get }
    var objectTypeId: String { get }
    var objectTypesConfigPublisher: AnyPublisher<ObjectTypesConfiguration, Never> { get }
    func setObjectTypeId(_ objectTypeId: String)
    
    func setDefaultObjectType(objectTypeId: BlockId) async throws
    func setDefaultTemplate(templateId: BlockId) async throws
}

final class SetObjectCreationSettingsInteractor: SetObjectCreationSettingsInteractorProtocol {
    
    var objectTypesAvailabilityPublisher: AnyPublisher<Bool, Never> { $canChangeObjectType.eraseToAnyPublisher() }
    
    var objectTypesConfigPublisher: AnyPublisher<ObjectTypesConfiguration, Never> {
        Publishers.CombineLatest($objectTypes, $objectTypeId)
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
    
    @Published var objectTypeId: String
    @Published var canChangeObjectType = false
    @Published private var objectTypes = [ObjectType]()
    
    let mode: SetObjectCreationSettingsMode
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    
    private let subscriptionService: TemplatesSubscriptionServiceProtocol
    private let objectTypesProvider: ObjectTypeProviderProtocol
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
        objectTypesProvider: ObjectTypeProviderProtocol,
        subscriptionService: TemplatesSubscriptionServiceProtocol,
        dataviewService: DataviewServiceProtocol
    ) {
        self.mode = mode
        self.setDocument = setDocument
        self.viewId = viewId
        self.dataView = setDocument.view(by: viewId)
        self.defaultTemplateId = dataView.defaultTemplateID ?? .empty
        self.subscriptionService = subscriptionService
        self.objectTypesProvider = objectTypesProvider
        self.dataviewService = dataviewService
        
        let defaultObjectType = try? setDocument.defaultObjectTypeForActiveView()
        let defaultObjectTypeID = defaultObjectType?.id ?? ""
        if defaultObjectTypeID.isEmpty {
            anytypeAssertionFailure("Couldn't find default object type", info: ["setId": setDocument.objectId])
        }
        
        if setDocument.isTypeSet() {
            if let firstSetOf = setDocument.details?.setOf.first {
                self.objectTypeId = firstSetOf
            } else {
                self.objectTypeId = defaultObjectTypeID
                anytypeAssertionFailure("Couldn't find default object type in sets", info: ["setId": setDocument.objectId])
            }
        } else {
            self.objectTypeId = defaultObjectTypeID
        }
        
        subscribeOnDocmentUpdates()
        loadTemplates()
    }
    
    func setObjectTypeId(_ objectTypeId: String) {
        updateState(with: objectTypeId)
    }
    
    func setDefaultObjectType(objectTypeId: BlockId) async throws {
        let updatedDataView = dataView.updated(defaultTemplateID: "", defaultObjectTypeID: objectTypeId)
        try await dataviewService.updateView(updatedDataView)
    }
    
    func setDefaultTemplate(templateId: BlockId) async throws {
        let updatedDataView = dataView.updated(defaultTemplateID: templateId)
        try await dataviewService.updateView(updatedDataView)
    }
    
    private func updateState(with objectTypeId: String) {
        self.objectTypeId = objectTypeId
        loadTemplates()
    }
    
    private func subscribeOnDocmentUpdates() {
        setDocument.syncPublisher.sink { [weak self] in
            guard let self else { return }
            dataView = setDocument.view(by: dataView.id)
            if defaultTemplateId != dataView.defaultTemplateID {
                defaultTemplateId = dataView.defaultTemplateID ?? .empty
            }
            
            guard mode == .default else { return }
            
            let defaultObjectTypeId = try? setDocument.defaultObjectTypeForView(dataView).id
            if !setDocument.isTypeSet(), let defaultObjectTypeId, objectTypeId != defaultObjectTypeId {
                updateState(with: defaultObjectTypeId)
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
    
        objectTypesProvider.syncPublisher.sink { [weak self] in
            self?.updateObjectTypes()
            self?.updateTypeDefaultTemplateId()
        }.store(in: &cancellables)
    }
    
    private func updateObjectTypes() {
        let objectTypes = objectTypesProvider.objectTypes.filter {
            guard let recommendedLayout = $0.recommendedLayout else { return false }
            return !$0.isArchived && DetailsLayout.visibleLayouts.contains(recommendedLayout)
        }
        self.objectTypes = objectTypes.reordered(
            by: [
                ObjectTypeUniqueKey.page.value,
                ObjectTypeUniqueKey.note.value,
                ObjectTypeUniqueKey.task.value,
                ObjectTypeUniqueKey.collection.value
            ]
        ) { $0.uniqueKey.value }
    }
    
    private func updateTypeDefaultTemplateId() {
        let defaultTemplateId = objectTypes.first { [weak self] in
            guard let self else { return false }
            return $0.id == objectTypeId
        }?.defaultTemplateId ?? .empty
        if typeDefaultTemplateId != defaultTemplateId {
            typeDefaultTemplateId = defaultTemplateId
        }
    }
    
    private func loadTemplates() {
        subscriptionService.startSubscription(objectType: objectTypeId, spaceId: setDocument.spaceId) { [weak self] _, update in
            guard let self else { return }
            templatesDetails.applySubscriptionUpdate(update)
            updateTypeDefaultTemplateId()
        }
    }
}
