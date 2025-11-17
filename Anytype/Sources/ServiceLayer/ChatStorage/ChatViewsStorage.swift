import Foundation
import Combine
import Services
import AnytypeCore

protocol ChatViewsStorageProtocol: AnyObject, Sendable {
    var allChats: [ObjectDetails] { get }
    var allChatsPublisher: AnyPublisher<[ObjectDetails], Never> { get }
    func startSubscription() async
    func stopSubscription() async
    func chat(id: String) -> ObjectDetails?
}

final class ChatViewsStorage: ChatViewsStorageProtocol {

    private let subscriptionBuilder: any ChatViewsSubscriptionBuilderProtocol = Container.shared.chatViewsSubscriptionBuilder()
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()
    private let subscriptionStorage: any SubscriptionStorageProtocol
    private let accountManager: any AccountManagerProtocol = Container.shared.accountManager()

    private let allChatsStorage = AtomicPublishedStorage<[ObjectDetails]>([])
    var allChats: [ObjectDetails] { allChatsStorage.value }
    var allChatsPublisher: AnyPublisher<[ObjectDetails], Never> {
        allChatsStorage.publisher
            .throttle(for: .milliseconds(50), scheduler: DispatchQueue.global(), latest: true)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    init() {
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionBuilder.subscriptionId)
    }

    func startSubscription() async {
        let data = subscriptionBuilder.build()
        try? await subscriptionStorage.startOrUpdateSubscription(data: data) { [weak self] data in
            guard let self else { return }
            allChatsStorage.value = data.items
        }
    }

    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }

    func chat(id: String) -> ObjectDetails? {
        return allChatsStorage.value.first(where: { $0.id == id })
    }
}
