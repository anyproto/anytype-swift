import Foundation
import Combine
import Services
import AnytypeCore

protocol SpaceViewsStorageProtocol: AnyObject, Sendable {
    var allSpaceViews: [SpaceView] { get }
    var allSpaceViewsPublisher: AnyPublisher<[SpaceView], Never> { get }
    func startSubscription() async
    func stopSubscription() async
    func spaceView(spaceViewId: String) -> SpaceView?
    func spaceView(spaceId: String) -> SpaceView?
    func spaceInfo(spaceId: String) -> AccountInfo?
    // TODO: Kostyl. Waiting when middleware to add method for receive account info without set active space
    func addSpaceInfo(spaceId: String, info: AccountInfo)
}

extension SpaceViewsStorageProtocol {

    var activeSpaceViews: [SpaceView] {
        allSpaceViews.filter(\.isActive)
    }

    var activeSpaceViewsPublisher: AnyPublisher<[SpaceView], Never> {
        allSpaceViewsPublisher.map { $0.filter(\.isActive) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func spaceViewPublisher(spaceId: String) -> AnyPublisher<SpaceView, Never> {
        allSpaceViewsPublisher.compactMap { $0.first { $0.targetSpaceId == spaceId } }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func spaceIsChat(spaceId: String) -> Bool {
        spaceView(spaceId: spaceId)?.uxType.isChat ?? false
    }
}

final class SpaceViewsStorage: SpaceViewsStorageProtocol {
    // MARK: - DI

    private let subscriptionBuilder: any SpaceViewsSubscriptionBuilderProtocol = Container.shared.spaceViewsSubscriptionBuilder()
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()
    private let subscriptionStorage: any SubscriptionStorageProtocol
    private let accountManager: any AccountManagerProtocol = Container.shared.accountManager()


    // MARK: - State

    private let spaceInfos = SynchronizedDictionary<String, AccountInfo>()

    private let allSpaceViewsStorage = AtomicPublishedStorage<[SpaceView]>([])
    var allSpaceViews: [SpaceView] { allSpaceViewsStorage.value }
    var allSpaceViewsPublisher: AnyPublisher<[SpaceView], Never> {
        allSpaceViewsStorage.publisher
            .throttle(for: .milliseconds(50), scheduler: DispatchQueue.global(), latest: true)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    init() {
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionBuilder.subscriptionId)
    }

    func startSubscription() async {
        let data = subscriptionBuilder.build(techSpaceId: accountManager.account.info.techSpaceId)
        try? await subscriptionStorage.startOrUpdateSubscription(data: data) { [weak self] data in
            guard let self else { return }

            let spaces = data.items.map { SpaceView(details: $0) }
            allSpaceViewsStorage.value = spaces
        }
    }

    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }

    func spaceView(spaceViewId: String) -> SpaceView? {
        return allSpaceViewsStorage.value.first(where: { $0.id == spaceViewId })
    }

    func spaceView(spaceId: String) -> SpaceView? {
        return allSpaceViewsStorage.value.first(where: { $0.targetSpaceId == spaceId })
    }


    func spaceInfo(spaceId: String) -> AccountInfo? {
        spaceInfos[spaceId]
    }

    func addSpaceInfo(spaceId: String, info: AccountInfo) {
        spaceInfos[spaceId] = info
    }

}
