import Foundation
import Services

protocol ContactsServiceProtocol: Sendable {
    func loadContacts() async -> [Contact]
    func prefetch() async
}

actor ContactsService: ContactsServiceProtocol {

    private let accountManager: any AccountManagerProtocol = Container.shared.accountManager()
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
        let subId = "ContactsService-\(UUID().uuidString)"
        let subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subId)

        let filters: [DataviewFilter] = .builder {
            SearchHelper.layoutFilter([.participant])
            SearchHelper.participantStatusFilter(.active)
            SearchHelper.notIdentity(accountManager.account.id)
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

            var contacts: [Contact] = []
            var spaceCounts: [String: Int] = [:]
            var seen = Set<String>()

            for await state in subscriptionStorage.statePublisher.values {
                let participants = state.items.compactMap { try? Participant(details: $0) }

                // Count spaces per identity
                for participant in participants where participant.identity.isNotEmpty {
                    spaceCounts[participant.identity, default: 0] += 1
                }

                // Deduplicate by identity
                for participant in participants {
                    guard participant.identity.isNotEmpty, !seen.contains(participant.identity) else { continue }
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

            return ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)
        } catch {
            return []
        }
    }
}
