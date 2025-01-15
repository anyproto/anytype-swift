@preconcurrency import Combine
import Services
import AnytypeCore

@MainActor
protocol SetObjectCreationSettingsInteractorProtocol {
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> { get }
    
    var objectTypesAvailabilityPublisher: AnyPublisher<Bool, Never> { get }
    var objectTypeId: String { get }
    var objectTypesConfigPublisher: AnyPublisher<ObjectTypesConfiguration, Never> { get }
    
    func setDefaultObjectType(objectTypeId: String) async throws
    func setDefaultTemplate(templateId: String) async throws
}

@MainActor
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
                        decoration: $0.id == templateId ? .border : nil
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    @Published var objectTypeId: String
    @Published var canChangeObjectType = false
    @Published private var objectTypes = [ObjectType]()
    
    private let setDocument: any SetDocumentProtocol
    private let viewId: String
    
    @Injected(\.templatesSubscription)
    private var templatesSubscription: any TemplatesSubscriptionServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypesProvider: any ObjectTypeProviderProtocol
    @Injected(\.typesService)
    private var typesService: any TypesServiceProtocol
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol
    
    @Published private var templatesDetails = [ObjectDetails]()
    @Published private var defaultTemplateId: String
    @Published private var typeDefaultTemplateId: String = ""
    
    private var dataView: DataviewView
    
    private var cancellables = [AnyCancellable]()
    
    init(
        setDocument: some SetDocumentProtocol,
        viewId: String
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.dataView = setDocument.view(by: viewId)
        self.defaultTemplateId = dataView.defaultTemplateID ?? ""
        
        let defaultObjectType = try? setDocument.defaultObjectTypeForActiveView()
        let defaultObjectTypeID = defaultObjectType?.id ?? ""
        if defaultObjectTypeID.isEmpty {
            anytypeAssertionFailure("Couldn't find default object type", info: ["setId": setDocument.objectId])
        }
        
        if setDocument.isTypeSet() {
            if let firstSetOf = setDocument.details?.filteredSetOf.first {
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
    
    func setDefaultObjectType(objectTypeId: String) async throws {
        let updatedDataView = dataView.updated(defaultTemplateID: "", defaultObjectTypeID: objectTypeId)
        try await dataviewService.updateView(objectId: setDocument.objectId, blockId: setDocument.blockId, view: updatedDataView)
    }
    
    func setDefaultTemplate(templateId: String) async throws {
        guard dataView.defaultTemplateID != templateId else { return }
        let updatedDataView = dataView.updated(defaultTemplateID: templateId)
        try await dataviewService.updateView(objectId: setDocument.objectId, blockId: setDocument.blockId, view: updatedDataView)
    }
    
    private func updateState(with objectTypeId: String) {
        self.objectTypeId = objectTypeId
        loadTemplates()
    }
    
    private func subscribeOnDocmentUpdates() {
        setDocument.syncPublisher.receiveOnMain().sink { [weak self] in
            guard let self else { return }
            dataView = setDocument.view(by: dataView.id)
            if defaultTemplateId != dataView.defaultTemplateID {
                defaultTemplateId = dataView.defaultTemplateID ?? ""
            }
            updateDefaultObjectTypeIdIfNeeded()
        }.store(in: &cancellables)
        
        setDocument.detailsPublisher.receiveOnMain().sink { [weak self] details in
            guard let self else { return }
            let isNotTypeSet = !setDocument.isTypeSet()
            if canChangeObjectType != isNotTypeSet {
                canChangeObjectType = isNotTypeSet
            }
        }
        .store(in: &cancellables)
    
        objectTypesProvider.syncPublisher.receiveOnMain().sink { [weak self] in
            self?.updateObjectTypes()
            self?.updateDefaultObjectTypeIdIfNeeded()
            self?.updateTypeDefaultTemplateId()
        }.store(in: &cancellables)
    }
    
    private func updateDefaultObjectTypeIdIfNeeded() {
        let defaultObjectTypeId = try? setDocument.defaultObjectTypeForView(dataView).id
        if !setDocument.isTypeSet(), let defaultObjectTypeId, objectTypeId != defaultObjectTypeId {
            updateState(with: defaultObjectTypeId)
        }
    }
    
    private func updateObjectTypes() {
        Task {
            objectTypes = try await typesService.searchObjectTypes(
                text: "", 
                includePins: true,
                includeLists: true,
                includeBookmarks: true,
                includeFiles: false,
                includeChat: false,
                includeTemplates: false,
                incudeNotForCreation: false,
                spaceId: setDocument.spaceId
            ).map { ObjectType(details: $0) }
        }
    }
    
    private func updateTypeDefaultTemplateId() {
        let defaultTemplateId = objectTypes.first { [weak self] in
            guard let self else { return false }
            return $0.id == objectTypeId
        }?.defaultTemplateId ?? ""
        if typeDefaultTemplateId != defaultTemplateId {
            typeDefaultTemplateId = defaultTemplateId
        }
    }
    
    private func loadTemplates() {
        Task {
            await templatesSubscription.startSubscription(objectType: objectTypeId, spaceId: setDocument.spaceId) { [weak self] details in
                await self?.handleTemplates(details: details)
            }
        }
    }
    
    private func handleTemplates(details: [ObjectDetails]) {
        templatesDetails = details
        updateTypeDefaultTemplateId()
    }
}
