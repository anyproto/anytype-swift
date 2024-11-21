import Foundation
import Services
import Combine
import AnytypeCore

protocol ObjectsListSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        objectTypeId: String,
        spaceId: String,
        update: @escaping ([ObjectDetails], Int) -> Void
    ) async
    func stopSubscription() async
}

actor ObjectsListSubscriptionService: ObjectsListSubscriptionServiceProtocol {
    private let subscriptionId = "ObjectsListSubscriptionService-\(UUID().uuidString)"
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    func startSubscription(
        objectTypeId: String,
        spaceId: String,
        update: @escaping ([ObjectDetails], Int) -> Void
    ) async {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.addedDate,
            type: .asc
        )
        let filter = SearchHelper.typeFilter([objectTypeId])
        let keys: [BundledRelationKey] = .builder {
            BundledRelationKey.createdDate
            BundledRelationKey.lastModifiedDate
            BundledRelationKey.objectListKeys
        }
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                spaceId: spaceId,
                sorts: [sort],
                filters: [filter],
                limit: 20,
                offset: 0,
                keys: keys.map { $0.rawValue }
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData) { data in
            update(data.items, data.nextCount)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
