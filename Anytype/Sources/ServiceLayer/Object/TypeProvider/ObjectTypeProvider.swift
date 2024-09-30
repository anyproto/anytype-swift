import AnytypeCore
import Services
import ProtobufMessages
import Combine

enum ObjectTypeError: Error {
    case objectTypeNotFound
}

final class ObjectTypeProvider: ObjectTypeProviderProtocol {
    
    private enum Constants {
        static let subscriptionIdPrefix = "SubscriptionId.ObjectType-"
    }
    
    // MARK: - Shared
    
    static let shared: any ObjectTypeProviderProtocol = ObjectTypeProvider()
    
    // MARK: - DI
    
    @Injected(\.objectTypeSubscriptionDataBuilder)
    private var subscriptionBuilder: any ObjectTypeSubscriptionDataBuilderProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.workspaceStorage)
    private var workspacessStorage: any WorkspacesStorageProtocol
    private var userDefaults: any UserDefaultsStorageProtocol
    
    // MARK: - Private variables
        
    private var objectTypes = SynchronizedDictionary<String, [ObjectType]>()
    private var searchTypesById = SynchronizedDictionary<String, ObjectType>()
    private var subscriptionStorages = SynchronizedDictionary<String, any SubscriptionStorageProtocol>()
    private var spacesSubscription: AnyCancellable?
    
    @Published private var defaultObjectTypes: [String: String] {
        didSet {
            userDefaults.defaultObjectTypes = defaultObjectTypes
        }
    }
    @Published var sync: () = ()
    var syncPublisher: AnyPublisher<Void, Never> { $sync.eraseToAnyPublisher() }

    private init() {
        let userDefaults = Container.shared.userDefaultsStorage()
        self.userDefaults = userDefaults
        defaultObjectTypes = userDefaults.defaultObjectTypes
    }
    
    // MARK: - ObjectTypeProviderProtocol
    
    func defaultObjectTypePublisher(spaceId: String) -> AnyPublisher<ObjectType, Never> {
        return $defaultObjectTypes.combineLatest(syncPublisher)
            .compactMap { [weak self] storage, _ in try? self?.defaultObjectType(storage: storage, spaceId: spaceId) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func defaultObjectType(spaceId: String) throws -> ObjectType {
       return try defaultObjectType(storage: defaultObjectTypes, spaceId: spaceId)
    }
    
    func setDefaultObjectType(type: ObjectType, spaceId: String, route: AnalyticsDefaultObjectTypeChangeRoute) {
        defaultObjectTypes[spaceId] = type.id
        AnytypeAnalytics.instance().logDefaultObjectTypeChange(type.analyticsType, route: route)
    }

    func objectType(id: String) throws -> ObjectType {
        guard let result = searchTypesById[id] else {
            throw ObjectTypeError.objectTypeNotFound
        }
        return result
    }
    
    func objectType(recommendedLayout: DetailsLayout, spaceId: String) throws -> ObjectType {
        let result = objectTypes(spaceId: spaceId).filter { $0.recommendedLayout == recommendedLayout }
        if result.count > 1 {
            anytypeAssertionFailure("Multiple types contains recommendedLayout", info: ["recommendedLayout": "\(recommendedLayout.rawValue)"])
        }
        guard let first = result.first else {
            anytypeAssertionFailure("Object type not found by recommendedLayout", info: ["recommendedLayout": "\(recommendedLayout.rawValue)"])
            throw ObjectTypeError.objectTypeNotFound
        }
        return first
    }
    
    func objectType(uniqueKey: ObjectTypeUniqueKey, spaceId: String) throws -> ObjectType {
        let result = objectTypes(spaceId: spaceId).filter { $0.uniqueKey == uniqueKey }
        if result.count > 1 {
            anytypeAssertionFailure("Multiple types contains uniqueKey", info: ["uniqueKey": "\(uniqueKey)"])
        }
        
        guard let first = result.first else {
            anytypeAssertionFailure("Object type not found by uniqueKey", info: ["uniqueKey": "\(uniqueKey)"])
            throw ObjectTypeError.objectTypeNotFound
        }
        return first
    }
    
    func objectTypes(spaceId: String) -> [ObjectType] {
        return objectTypes[spaceId] ?? []
    }
    
    func deletedObjectType(id: String) -> ObjectType {
        return ObjectType(
            id: id,
            name: Loc.ObjectType.deletedName,
            iconEmoji: nil,
            description: "",
            hidden: false,
            readonly: true,
            isArchived: false,
            isDeleted: true,
            sourceObject: "",
            spaceId: "",
            uniqueKey: .empty,
            defaultTemplateId: "",
            canCreateObjectOfThisType: false,
            recommendedRelations: [],
            recommendedLayout: nil
        )
    }
    
    func startSubscription() async {
        // Start first subscription in current async context for guarantee data state before return
        let spaceIds = await workspacessStorage.allWorkspaces.map { $0.targetSpaceId }
        await updateSubscriptions(spaceIds: spaceIds)
        
        spacesSubscription = await workspacessStorage.allWorkspsacesPublisher
            .map { $0.map { $0.targetSpaceId } }
            .removeDuplicates()
            .sink { [weak self] spaceIds in
                Task {
                    await self?.updateSubscriptions(spaceIds: spaceIds)
                }
            }
    }
    
    func stopSubscription() async {
        spacesSubscription?.cancel()
        spacesSubscription = nil
        for subscriptionStorage in subscriptionStorages.values {
            try? await subscriptionStorage.stopSubscription()
        }
        subscriptionStorages.removeAll()
        objectTypes.removeAll()
        updateAllCache()
    }
    
    // MARK: - Private func
    
    private func updateAllCache() {
        updateSearchCache()
    }
    
    private func updateSearchCache() {
        searchTypesById.removeAll()
        let types = objectTypes.values.flatMap { $0 }
        types.forEach {
            if searchTypesById[$0.id] != nil {
                anytypeAssertionFailure("Dublicate object type found", info: ["id": $0.id])
            }
            searchTypesById[$0.id] = $0
        }
    }
    
    private func findNoteType(spaceId: String) -> ObjectType? {
        return objectTypes(spaceId: spaceId).first { $0.uniqueKey == .note }
    }
    
    private func defaultObjectType(storage: [String: String], spaceId: String) throws -> ObjectType {
        let typeId = storage[spaceId]
        guard let type = objectTypes(spaceId: spaceId).first(where: { $0.id == typeId }) ?? findNoteType(spaceId: spaceId) else {
            throw ObjectTypeError.objectTypeNotFound
        }
        return type
    }
    
    private func updateStorage(data: SubscriptionStorageState, spaceId: String) {
        objectTypes[spaceId] = data.items.map { ObjectType(details: $0) }
        updateAllCache()
        sync = ()
    }
    
    private func updateSubscriptions(spaceIds: [String]) async {
        for spaceId in spaceIds {
            if subscriptionStorages[spaceId].isNil {
                let subId = Constants.subscriptionIdPrefix + spaceId
                let subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subId)
                subscriptionStorages[spaceId] = subscriptionStorage
                try? await subscriptionStorage.startOrUpdateSubscription(data: subscriptionBuilder.build(spaceId: spaceId, subId: subId)) { [weak self] data in
                    self?.updateStorage(data: data, spaceId: spaceId)
                }
            }
        }
    }
}
