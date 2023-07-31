import AnytypeCore
import Services
import ProtobufMessages
import Combine

extension ObjectType: IdProvider {}

enum ObjectTypeError: Error {
    case objectTypeNotFound
}

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
    var defaultObjectType: ObjectType = .emptyType
    var defaultObjectTypePublisher: AnyPublisher<ObjectType, Never> { $defaultObjectType.eraseToAnyPublisher() }
    
    func setDefaulObjectType(type: ObjectType) {
        UserDefaultsConfig.defaultObjectType = type
        updateDefaultObjectType()
    }
    
    func objectType(id: String) throws -> ObjectType {
        guard let result = searchTypesById[id] else {
            anytypeAssertionFailure("Object type not found by id", info: ["id": id])
            throw ObjectTypeError.objectTypeNotFound
        }
        return result
    }
    
    func objectType(recommendedLayout: DetailsLayout) throws -> ObjectType {
        let result = objectTypes.filter { $0.recommendedLayout == recommendedLayout }
        if result.count > 1 {
            anytypeAssertionFailure("Multiple types contains recommendedLayout", info: ["recommendedLayout": "\(recommendedLayout.rawValue)"])
        }
        guard let first = result.first else {
            anytypeAssertionFailure("Object type not found by recommendedLayout", info: ["recommendedLayout": "\(recommendedLayout.rawValue)"])
            throw ObjectTypeError.objectTypeNotFound
        }
        return first
    }
    
    func objectType(uniqueKey: ObjectTypeUniqueKey) throws -> ObjectType {
        let result = objectTypes.filter { $0.uniqueKey == uniqueKey }
        if result.count > 1 {
            anytypeAssertionFailure("Multiple types contains uniqueKey", info: ["uniqueKey": "\(uniqueKey.rawValue)"])
        }
        
        guard let first = result.first else {
            anytypeAssertionFailure("Object type not found by uniqueKey", info: ["uniqueKey": "\(uniqueKey.rawValue)"])
            throw ObjectTypeError.objectTypeNotFound
        }
        return first
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
            uniqueKey: nil,
            recommendedRelations: [],
            recommendedLayout: nil
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
                anytypeAssertionFailure("Dublicate object type found", info: ["id": $0.id])
            }
            searchTypesById[$0.id] = $0
        }
    }
    
    private func updateDefaultObjectType() {
        let type = UserDefaultsConfig.defaultObjectType
        defaultObjectType = objectTypes.first { $0.id == type.id } ?? findNoteType() ?? .emptyType
    }
    
    private func findNoteType() -> ObjectType? {
        let type = objectTypes.first { $0.uniqueKey == .note }
        if type.isNil {
            anytypeAssertionFailure("Note type not found")
        }
        return type
    }
}
