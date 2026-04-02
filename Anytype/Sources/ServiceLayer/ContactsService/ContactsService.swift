import Foundation
import Services

protocol ContactsServiceProtocol: Sendable {
    func loadContacts() async -> [Contact]
    func prefetch() async
}

actor ContactsService: ContactsServiceProtocol {

    private let spaceViewsStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()

    private var prefetchTask: Task<[Contact], Never>?

    func prefetch() {
        guard prefetchTask == nil else { return }
        prefetchTask = Task { await fetchContacts() }
    }

    func loadContacts() async -> [Contact] {
        if let task = prefetchTask {
            return await task.value
        }
        return await fetchContacts()
    }

    // MARK: - Private

    private func fetchContacts() async -> [Contact] {
        let oneToOneSpaces = spaceViewsStorage.allSpaceViews.filter {
            $0.isOneToOne && $0.isActive
        }
        guard oneToOneSpaces.isNotEmpty else {
            prefetchTask = nil
            return []
        }

        let identities = oneToOneSpaces.compactMap(\.oneToOneIdentity).filter(\.isNotEmpty)
        guard identities.isNotEmpty else {
            prefetchTask = nil
            return []
        }

        let subId = "ContactsService-\(UUID().uuidString)"
        let subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subId)

        let filters: [DataviewFilter] = .builder {
            SearchHelper.layoutFilter([.participant])
            SearchHelper.participantStatusFilter(.active)
            SearchHelper.identities(identities)
        }

        let searchData: SubscriptionData = .crossSpaceSearch(
            SubscriptionData.CrossSpaceSearch(
                identifier: subId,
                filters: filters,
                keys: Participant.subscriptionKeys.map(\.rawValue),
                noDepSubscription: true
            )
        )

        defer {
            prefetchTask = nil
            Task { try? await subscriptionStorage.stopSubscription() }
        }

        do {
            try await subscriptionStorage.startOrUpdateSubscription(data: searchData)

            let identitySet = Set(identities)
            var contacts: [Contact] = []
            var seen = Set<String>()

            for await state in subscriptionStorage.statePublisher.values {
                let participants = state.items.compactMap { try? Participant(details: $0) }
                for participant in participants {
                    guard identitySet.contains(participant.identity), !seen.contains(participant.identity) else { continue }
                    seen.insert(participant.identity)
                    contacts.append(Contact(
                        identity: participant.identity,
                        name: participant.title,
                        globalName: participant.displayGlobalName,
                        icon: participant.icon
                    ))
                }
                break
            }

            return contacts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            return []
        }
    }
}
