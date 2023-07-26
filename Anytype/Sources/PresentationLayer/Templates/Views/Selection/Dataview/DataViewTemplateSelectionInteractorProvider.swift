import Combine
import Services
import AnytypeCore

protocol TemplateSelectionInteractorProvider {
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> { get }
    var objectTypeId: ObjectTypeId { get }
    
    func setDefaultTemplate(model: TemplatePreviewModel) async throws
}

final class DataviewTemplateSelectionInteractorProvider: TemplateSelectionInteractorProvider {
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> {
        Publishers.CombineLatest($templatesDetails, $defaultTemplateId)
            .map { details, defaultTemplateId in
                details.map {
                    TemplatePreviewModel(
                        objectDetails: $0,
                        isDefault: $0.id == defaultTemplateId
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    let objectTypeId: ObjectTypeId
    
    private let setDocument: SetDocumentProtocol
    private let dataView: DataviewView
    
    private let subscriptionService: TemplatesSubscriptionServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let dataviewService: DataviewServiceProtocol
    
    @Published private var templatesDetails = [ObjectDetails]()
    @Published private var defaultTemplateId: BlockId
    
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
        
        if setDocument.isCollection() || setDocument.isRelationsSet() {
            self.objectTypeId = .dynamic(objectTypeProvider.defaultObjectType.id)
        } else {
            if let firstSetOf = setDocument.details?.setOf.first {
                self.objectTypeId = .dynamic(firstSetOf)
            } else {
                self.objectTypeId = .dynamic(objectTypeProvider.defaultObjectType.id)
                anytypeAssertionFailure("Couldn't find default object type in sets", info: ["setId": setDocument.objectId])
            }
        }
        
        subscribeOnDocmentUpdates()
        loadTemplates()
    }
    
    private func subscribeOnDocmentUpdates() {
        setDocument.activeViewPublisher.sink { [weak self] activeDataView in
            guard let self = self else { return }
            if self.defaultTemplateId != activeDataView.defaultTemplateID {
                self.defaultTemplateId = activeDataView.defaultTemplateID ?? .empty
            }
        }.store(in: &cancellables)
        
        
        setDocument.updatePublisher.sink { [weak self] _ in
            guard let self = self,
                  let view = self.setDocument.dataView.views.first(where: { $0.id == self.dataView.id }) else {
                anytypeAssertionFailure(
                    "Can't find selected dataView for template picker",
                    info: ["DataView.Id": self?.dataView.id ?? .empty]
                )
                return
            }
            if self.defaultTemplateId != view.defaultTemplateID {
                self.defaultTemplateId = view.defaultTemplateID ?? .empty
            }
        }.store(in: &cancellables)
    }
    
    private func loadTemplates() {
        subscriptionService.startSubscription(objectType: objectTypeId, spaceId: setDocument.spaceId) { [weak self] _, update in
            self?.templatesDetails.applySubscriptionUpdate(update)
        }
    }
    
    func setDefaultTemplate(model: TemplatePreviewModel) async throws {
        let updatedDataView = dataView.updated(defaultTemplateID: model.id)
        try await dataviewService.updateView(updatedDataView)
    }
}
