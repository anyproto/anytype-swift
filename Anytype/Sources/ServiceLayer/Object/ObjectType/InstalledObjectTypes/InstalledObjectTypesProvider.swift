import AnytypeCore
import Services
import ProtobufMessages
import Combine

protocol InstalledObjectTypesProviderProtocol: AnyObject {
    var objectTypes: [ObjectType] { get }
    var objectTypesPublisher: AnyPublisher<[ObjectType], Never> { get }

    func startSubscription() async
}

final class InstalledObjectTypesProvider: InstalledObjectTypesProviderProtocol {
    
    static let subscriptionId = "SubscriptionId.InstalledObjectTypes"

    // MARK: - ObjectTypeProviderProtocol
    
    private var objectDetails = [ObjectDetails]()

    @Published var objectTypes = [ObjectType]()
    var objectTypesPublisher: AnyPublisher<[ObjectType], Never> { $objectTypes.eraseToAnyPublisher() }

    // MARK: - Private variables
    
    private let subscriptionsService: SubscriptionsServiceProtocol
    private let subscriptionBuilder: InstalledObjectTypesSubscriptionDataBuilderProtocol

    init(
        subscriptionsService: SubscriptionsServiceProtocol,
        subscriptionBuilder: InstalledObjectTypesSubscriptionDataBuilderProtocol
    ) {
        self.subscriptionsService = subscriptionsService
        self.subscriptionBuilder = subscriptionBuilder
    }

    func startSubscription() async {
        await subscriptionsService.startSubscriptionAsync(data: subscriptionBuilder.build()) { [weak self] subId, update in
            self?.handleEvent(update: update)
        }
    }

    func stopSubscription() {
        subscriptionsService.stopSubscription(id: Self.subscriptionId)
        objectDetails.removeAll()
        objectTypes.removeAll()
    }

    // MARK: - Private func
    
    private func handleEvent(update: SubscriptionUpdate) {
        objectDetails.applySubscriptionUpdate(update)
        let reorderedObjectDetails = objectDetails.reordered(
            by: [
                ObjectTypeId.bundled(.page).rawValue,
                ObjectTypeId.bundled(.note).rawValue,
                ObjectTypeId.bundled(.task).rawValue,
                ObjectTypeId.bundled(.collection).rawValue
            ]
        ) { $0.id }
        objectTypes = reorderedObjectDetails.map { ObjectType(details: $0) }
    }
    
    deinit {
        stopSubscription()
    }
}
