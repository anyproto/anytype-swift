import Combine
import Services
import AnytypeCore

protocol TemplateSelectionInteractorProvider {
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> { get }
    var objectTypeId: String { get }
    
    func setDefaultTemplate(templateId: BlockId) async throws
}

final class DataviewTemplateSelectionInteractorProvider: TemplateSelectionInteractorProvider {
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
    
    let objectTypeId: String
    
    private let setDocument: SetDocumentProtocol
    private let dataView: DataviewView
    
    private let subscriptionService: TemplatesSubscriptionServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let dataviewService: DataviewServiceProtocol
    
    @Published private var templatesDetails = [ObjectDetails]()
    @Published private var defaultTemplateId: BlockId
    @Published private var typeDefaultTemplateId: BlockId
    
    private var cancellables = [AnyCancellable]()
    
    init(
        setDocument: SetDocumentProtocol,
        dataView: DataviewView,
        objectTypeProvider: ObjectTypeProviderProtocol,
        subscriptionService: TemplatesSubscriptionServiceProtocol,
        dataviewService: DataviewServiceProtocol
    ) {
        self.setDocument = setDocument
        self.dataView = dataView
        self.defaultTemplateId = dataView.defaultTemplateID ?? .empty
        self.subscriptionService = subscriptionService
        self.objectTypeProvider = objectTypeProvider
        self.dataviewService = dataviewService
        
        let defaultObjectType = try? setDocument.defaultObjectTypeForActiveView()
        if defaultObjectType.isNil {
            anytypeAssertionFailure("Couldn't find default object type", info: ["setId": setDocument.objectId])
        }
        
        if setDocument.isTypeSet() {
            if let firstSetOf = setDocument.details?.setOf.first {
                self.objectTypeId = firstSetOf
            } else {
                self.objectTypeId = defaultObjectType?.id ?? ""
                anytypeAssertionFailure("Couldn't find default object type in sets", info: ["setId": setDocument.objectId])
            }
        } else {
            self.objectTypeId = defaultObjectType?.id ?? ""
        }
        
        self.typeDefaultTemplateId = defaultObjectType?.defaultTemplateId ?? ""
        
        subscribeOnDocmentUpdates()
        loadTemplates()
    }
    
    private func subscribeOnDocmentUpdates() {
        setDocument.activeViewPublisher.sink { [weak self] activeDataView in
            guard let self else { return }
            if self.defaultTemplateId != activeDataView.defaultTemplateID {
                self.defaultTemplateId = activeDataView.defaultTemplateID ?? .empty
            }
        }.store(in: &cancellables)
        
        objectTypeProvider.syncPublisher.sink { [weak self] in
            guard let self else { return }
            let defaultTemplateId = (try? objectTypeProvider.objectType(id: objectTypeId))?.defaultTemplateId ?? .empty
            if typeDefaultTemplateId != defaultTemplateId {
                typeDefaultTemplateId = defaultTemplateId
            }
        }.store(in: &cancellables)
    }
    
    private func loadTemplates() {
        subscriptionService.startSubscription(objectType: objectTypeId, spaceId: setDocument.spaceId) { [weak self] _, update in
            self?.templatesDetails.applySubscriptionUpdate(update)
        }
    }
    
    func setDefaultTemplate(templateId: BlockId) async throws {
        let updatedDataView = dataView.updated(defaultTemplateID: templateId)
        try await dataviewService.updateView(updatedDataView)
    }
}
