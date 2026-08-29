import Foundation
import Services
import AsyncTools
import AsyncAlgorithms

// All type objects across all spaces, filled by one vault-wide subscription.
// Resolves type captions for cross-space search results - never fetch types
// per space or per row.
protocol CrossSpaceTypesStorageProtocol: AnyObject, Sendable {
    var allTypesSequence: AnyAsyncSequence<[ObjectDetails]> { get async }
    func startSubscription() async
    func stopSubscription() async
}

actor CrossSpaceTypesStorage: CrossSpaceTypesStorageProtocol {

    private let subscriptionBuilder: any CrossSpaceTypesSubscriptionBuilderProtocol = Container.shared.crossSpaceTypesSubscriptionBuilder()
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()
    private let subscriptionStorage: any SubscriptionStorageProtocol

    private let allTypesStream = AsyncToManyStream<[ObjectDetails]>()

    var allTypesSequence: AnyAsyncSequence<[ObjectDetails]> {
        allTypesStream
            .subscribe([])
            .throttle(milliseconds: 300, latest: true)
            .removeDuplicates()
            .eraseToAnyAsyncSequence()
    }

    init() {
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionBuilder.subscriptionId)
    }

    func startSubscription() async {
        let data = subscriptionBuilder.build()
        try? await subscriptionStorage.startOrUpdateSubscription(data: data) { [weak self] data in
            guard let self else { return }
            self.allTypesStream.send(data.items)
        }
    }

    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
