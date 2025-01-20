import Foundation
import Services
@preconcurrency import Combine
import AnytypeCore

protocol TemplatesSubscriptionServiceProtocol: AnyObject, Sendable {
    func startSubscription(
        objectType: String,
        spaceId: String,
        update: (@Sendable ([ObjectDetails]) async -> Void)? // For legacy editor code
    ) async -> AnyPublisher<[ObjectDetails], Never>
    func stopSubscription() async
}

actor TemplatesSubscriptionService: TemplatesSubscriptionServiceProtocol {
    private let subscriptionId = "Templates-\(UUID().uuidString)"
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    func startSubscription(
        objectType: String,
        spaceId: String,
        update: (@Sendable ([ObjectDetails]) async -> Void)?
    ) async -> AnyPublisher<[ObjectDetails], Never> {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.addedDate,
            type: .desc
        )
        let filters = SearchHelper.templatesFilters(type: objectType)
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                spaceId: spaceId,
                sorts: [sort],
                filters: filters,
                limit: 100,
                offset: 0,
                keys: BundledRelationKey.templatePreviewKeys.map { $0.rawValue }
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData) { data in
            await update?(data.items)
        }
        return subscriptionStorage.statePublisher.map { $0.items }.eraseToAnyPublisher()
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
