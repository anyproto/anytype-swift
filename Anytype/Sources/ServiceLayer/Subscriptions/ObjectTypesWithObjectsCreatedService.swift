import Foundation
import Services
import Combine
import AnytypeCore

@MainActor
protocol ObjectTypesWithObjectsCreatedServiceProtocol: AnyObject {
    @available(*, deprecated, message: "Use spaceType overload instead")
    func startSubscription(spaceId: String, spaceUxType: SpaceUxType?) async
    func startSubscription(spaceId: String, spaceType: SpaceType?) async
    func stopSubscription() async
    var typeIdsWithObjectsCreatedPublisher: AnyPublisher<Set<String>, Never> { get }
}

@MainActor
final class ObjectTypesWithObjectsCreatedService: ObjectTypesWithObjectsCreatedServiceProtocol {

    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol

    private let subscriptionId = "ObjectTypesWithObjectsCreated-\(UUID().uuidString)"
    private let typeIdsSubject = CurrentValueSubject<Set<String>, Never>([])
    private var subscriptionStorage: (any SubscriptionStorageProtocol)?
    private var cancellable: AnyCancellable?

    nonisolated init() {}
    
    deinit { Task { @MainActor [subscriptionStorage]  in
        try? await subscriptionStorage?.stopSubscription()
    } }

    var typeIdsWithObjectsCreatedPublisher: AnyPublisher<Set<String>, Never> {
        typeIdsSubject.eraseToAnyPublisher()
    }

    func startSubscription(spaceId: String, spaceUxType: SpaceUxType?) async {
        guard subscriptionStorage == nil else { return }

        let storage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
        subscriptionStorage = storage

        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters()
            SearchHelper.layoutFilter(DetailsLayout.widgetTypeLayouts(spaceUxType: spaceUxType))
            SearchHelper.templateScheme(include: false)
        }

        await startSubscriptionWithFilters(storage: storage, spaceId: spaceId, filters: filters)
    }

    func startSubscription(spaceId: String, spaceType: SpaceType?) async {
        guard subscriptionStorage == nil else { return }

        let storage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
        subscriptionStorage = storage

        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters()
            SearchHelper.layoutFilter(DetailsLayout.widgetTypeLayouts(spaceType: spaceType))
            SearchHelper.templateScheme(include: false)
        }

        await startSubscriptionWithFilters(storage: storage, spaceId: spaceId, filters: filters)
    }

    private func startSubscriptionWithFilters(storage: any SubscriptionStorageProtocol, spaceId: String, filters: [DataviewFilter]) async {
        let data = SubscriptionData.search(SubscriptionData.Search(
            identifier: subscriptionId,
            spaceId: spaceId,
            filters: filters,
            limit: 0,
            keys: [BundledPropertyKey.id.rawValue, BundledPropertyKey.type.rawValue],
            noDepSubscription: true
        ))

        cancellable = storage.statePublisher
            .sink { [weak self] state in
                self?.updateTypeIds(from: state.items)
            }

        do {
            try await storage.startOrUpdateSubscription(data: data)
        } catch {
            anytypeAssertionFailure("Failed to start objects subscription", info: ["error": error.localizedDescription])
        }
    }

    func stopSubscription() async {
        cancellable?.cancel()
        cancellable = nil
        try? await subscriptionStorage?.stopSubscription()
        subscriptionStorage = nil
        typeIdsSubject.send([])
    }

    private func updateTypeIds(from objects: [ObjectDetails]) {
        let typeIds = Set(objects.map(\.type).filter(\.isNotEmpty))
        typeIdsSubject.send(typeIds)
    }
}
