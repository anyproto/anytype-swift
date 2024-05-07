import AnytypeCore
import Services
import ProtobufMessages
import Combine

enum ObjectTypeError: Error {
    case objectTypeNotFound
}

final class ObjectTypeProvider: ObjectTypeProviderProtocol {
    
    static let shared: ObjectTypeProviderProtocol = ObjectTypeProvider(
        subscriptionBuilder: ObjectTypeSubscriptionDataBuilder(accountManager: ServiceLocator.shared.accountManager())
    )
    
    static let subscriptionId = "SubscriptionId.ObjectType"
    
    // MARK: - Private variables
    
    @Published private var defaultObjectTypes: [String: String] = UserDefaultsConfig.defaultObjectTypes {
        didSet {
            UserDefaultsConfig.defaultObjectTypes = defaultObjectTypes
        }
    }
    private let subscriptionStorage: SubscriptionStorageProtocol
    private let subscriptionBuilder: ObjectTypeSubscriptionDataBuilderProtocol
    
    private(set) var objectTypes = [ObjectType]()
    private var searchTypesById = SynchronizedDictionary<String, ObjectType>()
    
    @Published var sync: () = ()
    var syncPublisher: AnyPublisher<Void, Never> { $sync.eraseToAnyPublisher() }

    private init(
        subscriptionBuilder: ObjectTypeSubscriptionDataBuilderProtocol
    ) {
        self.subscriptionBuilder = subscriptionBuilder
       
        let storageProvider = Container.shared.subscriptionStorageProvider.resolve()
        self.subscriptionStorage = storageProvider.createSubscriptionStorage(subId: ObjectTypeProvider.subscriptionId)
    }
    
    // MARK: - ObjectTypeProviderProtocol
    
    func defaultObjectTypePublisher(spaceId: String) -> AnyPublisher<ObjectType, Never> {
        return $defaultObjectTypes
            .compactMap { [weak self] storage in try? self?.defaultObjectType(storage: storage, spaceId: spaceId) }
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
        let result = objectTypes.filter { $0.recommendedLayout == recommendedLayout && $0.spaceId == spaceId }
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
        let result = objectTypes.filter { $0.uniqueKey == uniqueKey && $0.spaceId == spaceId }
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
        return objectTypes.filter { $0.spaceId == spaceId }
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
        try? await subscriptionStorage.startOrUpdateSubscription(data: subscriptionBuilder.build()) { [weak self] data in
            self?.updateStorage(data: data)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
        objectTypes.removeAll()
        updateAllCache()
    }
    
    // MARK: - Private func
    
    private func updateAllCache() {
        updateSearchCache()
    }
    
    private func updateSearchCache() {
        searchTypesById.removeAll()
        objectTypes.forEach {
            if searchTypesById[$0.id] != nil {
                anytypeAssertionFailure("Dublicate object type found", info: ["id": $0.id])
            }
            searchTypesById[$0.id] = $0
        }
    }
    
    private func findNoteType(spaceId: String) -> ObjectType? {
        return objectTypes.first { $0.uniqueKey == .note && $0.spaceId == spaceId }
    }
    
    private func defaultObjectType(storage: [String: String], spaceId: String) throws -> ObjectType {
        let typeId = storage[spaceId]
        guard let type = objectTypes.first(where: { $0.id == typeId }) ?? findNoteType(spaceId: spaceId) else {
            throw ObjectTypeError.objectTypeNotFound
        }
        return type
    }
    
    private func updateStorage(data: SubscriptionStorageState) {
        objectTypes = data.items.map { ObjectType(details: $0) }
        updateAllCache()
        sync = ()
    }
}
