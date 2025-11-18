import Foundation
import Services
import AsyncTools
import AsyncAlgorithms

protocol ChatDetailsStorageProtocol: AnyObject, Sendable {
    func allChats() async -> [ObjectDetails]
    var allChatsSequence: AnyAsyncSequence<[ObjectDetails]> { get async }
    func startSubscription() async
    func stopSubscription() async
    func chat(id: String) async -> ObjectDetails?
}

actor ChatDetailsStorage: ChatDetailsStorageProtocol {

    private let subscriptionBuilder: any ChatDetailsSubscriptionBuilderProtocol = Container.shared.chatDetailsSubscriptionBuilder()
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()
    private let subscriptionStorage: any SubscriptionStorageProtocol

    private let allChatsStream = AsyncToManyStream<[ObjectDetails]>()

    func allChats() -> [ObjectDetails] {
        allChatsStream.value ?? []
    }

    var allChatsSequence: AnyAsyncSequence<[ObjectDetails]> {
        allChatsStream
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
            self.allChatsStream.send(data.items)
        }
    }

    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }

    func chat(id: String) -> ObjectDetails? {
        return allChatsStream.value?.first(where: { $0.id == id })
    }
}
