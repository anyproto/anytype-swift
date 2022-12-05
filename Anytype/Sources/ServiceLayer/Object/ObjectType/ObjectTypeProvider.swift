import AnytypeCore
import BlocksModels
import ProtobufMessages

extension ObjectType: IdProvider {}

final class ObjectTypeProvider: ObjectTypeProviderProtocol {
    
    private enum Constants {
        static let notVisibleSmartBlocks: [SmartBlockType] = [.file]
        static let notVisibleTypes: [String] = [
            ObjectTypeId.bundled(.template).rawValue,
            ObjectTypeId.bundled(.relation).rawValue,
            ObjectTypeId.bundled(.relationOption).rawValue,
            ObjectTypeId.bundled(.objectType).rawValue
        ]
        static let supportedForEditSmartblockTypes: [SmartBlockType] = [.page, .profilePage, .anytypeProfile, .set, .file]
    }
        
    static let shared: ObjectTypeProviderProtocol = ObjectTypeProvider(
        subscriptionsService: ServiceLocator.shared.subscriptionService(),
        subscriptionBuilder: ObjectTypeSubscriptionDataBuilder(accountManager: AccountManager.shared)
    )
    
    // MARK: - Private variables
    
    private let subscriptionsService: SubscriptionsServiceProtocol
    private let subscriptionBuilder: ObjectTypeSubscriptionDataBuilderProtocol
    
    
    private var objectTypes = [ObjectType]()
    private var searchTypesById = [String: ObjectType]()
    private var cachedSupportedTypeIds: [String] = []
    private var notVisibleTypeIdsCache: [String] = []
    
    private init(
        subscriptionsService: SubscriptionsServiceProtocol,
        subscriptionBuilder: ObjectTypeSubscriptionDataBuilderProtocol
    ) {
        self.subscriptionsService = subscriptionsService
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    // MARK: - ObjectTypeProviderProtocol
    
    func isSupportedForEdit(typeId: String) -> Bool {
        cachedSupportedTypeIds.contains(typeId)
    }
    
    var defaultObjectType: ObjectType {
        let type = UserDefaultsConfig.defaultObjectType
        return objectTypes.first { $0.id == type.id } ?? ObjectType.fallbackType
    }
    
    func setDefaulObjectType(id: String) {
        guard let type = objectTypes.first(where: { $0.id == id }) else { return }
        UserDefaultsConfig.defaultObjectType = type
    }
    
    func objectType(id: String) -> ObjectType? {
        return searchTypesById[id]
    }
    
    func objectTypes(smartblockTypes: Set<SmartBlockType>) -> [ObjectType] {
        objectTypes.filter {
            $0.smartBlockTypes.intersection(smartblockTypes).isNotEmpty
        }
    }
    
    func notVisibleTypeIds() -> [String] {
        return notVisibleTypeIdsCache
    }
    
    func startSubscription() {
        subscriptionsService.startSubscription(data: subscriptionBuilder.build()) { [weak self] subId, update in
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
        updateSupportedTypeIds()
        updateSearchCache()
        updateNotVisibleTypeIds()
    }
    
    private func updateSupportedTypeIds() {
        cachedSupportedTypeIds = objectTypes.filter {
            $0.smartBlockTypes.intersection(Constants.supportedForEditSmartblockTypes).isNotEmpty
        }.map { $0.id }
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
    
    private func updateNotVisibleTypeIds() {
        notVisibleTypeIdsCache = objectTypes.filter {
            $0.smartBlockTypes.intersection(Constants.notVisibleSmartBlocks).isNotEmpty
            || Constants.notVisibleTypes.contains($0.id)
        }.map { $0.id }
    }
}
