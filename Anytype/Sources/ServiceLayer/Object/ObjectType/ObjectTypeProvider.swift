import AnytypeCore
import BlocksModels
import ProtobufMessages

extension ObjectType: IdProvider {}

final class ObjectTypeProvider: ObjectTypeProviderProtocol {
        
    static let shared = ObjectTypeProvider(
        subscriptionsService: ServiceLocator.shared.subscriptionService(),
        subscriptionBuilder: ObjectTypeSubscriptionDataBuilder(accountManager: AccountManager.shared)
    )
    
    // MARK: - Private variables
    
    private let subscriptionsService: SubscriptionsServiceProtocol
    private let subscriptionBuilder: ObjectTypeSubscriptionDataBuilderProtocol
    private let supportedSmartblockTypes: Set<SmartBlockType> = [.page, .profilePage, .anytypeProfile, .set, .file]
    
    private var objectTypes = [ObjectType]()
    private var searchTypesById = [String: ObjectType]()
    private var cachedSupportedTypeIds: Set<String> = []
    
    private init(
        subscriptionsService: SubscriptionsServiceProtocol,
        subscriptionBuilder: ObjectTypeSubscriptionDataBuilderProtocol
    ) {
        self.subscriptionsService = subscriptionsService
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    // MARK: - ObjectTypeProviderProtocol
    
    var supportedTypeIds: [String] {
        Array(cachedSupportedTypeIds)
    }
    
    func isSupported(typeId: String) -> Bool {
        cachedSupportedTypeIds.contains(typeId)
    }
    
    var defaultObjectType: ObjectType {
        UserDefaultsConfig.defaultObjectType
    }
    
    func objectType(id: String) -> ObjectType? {
        return searchTypesById[id]
    }
    
    func objectTypes(smartblockTypes: Set<SmartBlockType>) -> [ObjectType] {
        objectTypes.filter {
            $0.smartBlockTypes.intersection(smartblockTypes).isNotEmpty
        }
    }
    
    func startSubscription() {
        subscriptionsService.startSubscription(data: subscriptionBuilder.build()) { [weak self] subId, update in
            self?.handleEvent(update: update)
        }
    }
    
    func stopSubscription() {
        subscriptionsService.stopSubscription(id: .objectType)
        objectTypes.removeAll()
        updateSupportedTypeIds()
        updateSearchCache()
    }
    
    // MARK: - Private func
    
    private func handleEvent(update: SubscriptionUpdate) {
        objectTypes.applySubscriptionUpdate(update, transform: { ObjectType(details: $0) })
        updateSupportedTypeIds()
        updateSearchCache()
    }
    
    private func updateSupportedTypeIds() {
        let result = objectTypes.filter {
                $0.smartBlockTypes.intersection(supportedSmartblockTypes).isNotEmpty
            }.map { $0.id }
        cachedSupportedTypeIds = Set(result)
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
}
