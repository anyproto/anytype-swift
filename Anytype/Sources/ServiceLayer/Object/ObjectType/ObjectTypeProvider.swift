import AnytypeCore
import BlocksModels
import ProtobufMessages
import Combine

extension ObjectType: IdProvider {}

final class ObjectTypeProvider: ObjectTypeProviderProtocol {
    
    static let shared: ObjectTypeProviderProtocol = ObjectTypeProvider(
        subscriptionsService: ServiceLocator.shared.subscriptionService(),
        subscriptionBuilder: ObjectTypeSubscriptionDataBuilder(accountManager: ServiceLocator.shared.accountManager())
    )
    
    // MARK: - Private variables
    
    private let subscriptionsService: SubscriptionsServiceProtocol
    private let subscriptionBuilder: ObjectTypeSubscriptionDataBuilderProtocol
    
    private(set) var objectTypes = [ObjectType]()
    private var searchTypesById = [String: ObjectType]()
    
    private init(
        subscriptionsService: SubscriptionsServiceProtocol,
        subscriptionBuilder: ObjectTypeSubscriptionDataBuilderProtocol
    ) {
        self.subscriptionsService = subscriptionsService
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    // MARK: - ObjectTypeProviderProtocol
    
    @Published
    var defaultObjectType: ObjectType = .fallbackType
    var defaultObjectTypePublisher: AnyPublisher<ObjectType, Never> { $defaultObjectType.eraseToAnyPublisher() }
    
    func setDefaulObjectType(type: ObjectType) {
        UserDefaultsConfig.defaultObjectType = type
        updateDefaultObjectType()
    }
    
    func objectType(id: String) -> ObjectType? {
        return searchTypesById[id]
    }
    
    func deleteObjectType(id: String) -> ObjectType {
        return ObjectType(
            id: id,
            name: Loc.ObjectType.deletedName,
            iconEmoji: .default,
            description: "",
            hidden: false,
            readonly: true,
            isArchived: false,
            isDeleted: true,
            sourceObject: "",
            recommendedRelations: []
        )
    }
    
    func startSubscription() async {
        await subscriptionsService.startSubscriptionAsync(data: subscriptionBuilder.build()) { [weak self] subId, update in
            self?.handleEvent(update: update)
        }
    }
    
    func stopSubscription() {
        subscriptionsService.stopSubscription(id: .objectType)
        objectTypes.removeAll()
        updateAllCache()
    }
    
    // MARK: - Private func
    
    private func handleEvent(update: SubscriptionUpdate) {
        objectTypes.applySubscriptionUpdate(update, transform: { ObjectType(details: $0) })
        updateAllCache()
    }
    
    private func updateAllCache() {
        updateSearchCache()
        updateDefaultObjectType()
    }
    
    private func updateSearchCache() {
        searchTypesById.removeAll()
        objectTypes.forEach {
            if searchTypesById[$0.id] != nil {
                anytypeAssertionFailure(
                    "Dublicate object type found for id: \($0.id), name: \($0.name)",
                    domain: .objectTypeProvider
                )
            }
            searchTypesById[$0.id] = $0
        }
    }
    
    private func updateDefaultObjectType() {
        let type = UserDefaultsConfig.defaultObjectType
        defaultObjectType = objectTypes.first { $0.id == type.id } ?? ObjectType.fallbackType
    }
}
