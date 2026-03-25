import Foundation
import Services
import Combine

protocol ContactsServiceProtocol: Sendable {
    func loadContacts() async -> [Contact]
}

final class ContactsService: ContactsServiceProtocol {

    private let spaceViewsStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()
    private let participantSubscriptionProvider: any ParticipantsSubscriptionProviderProtocol = Container.shared.participantSubscriptionProvider()

    func loadContacts() async -> [Contact] {
        let oneToOneSpaces = spaceViewsStorage.allSpaceViews.filter {
            $0.uxType == .oneToOne && $0.isActive
        }

        let contacts = await withTaskGroup(of: Contact?.self, returning: [Contact].self) { group in
            for spaceView in oneToOneSpaces {
                group.addTask { [participantSubscriptionProvider] in
                    let subscription = participantSubscriptionProvider.subscription(spaceId: spaceView.targetSpaceId)

                    for await participants in subscription.participantsPublisher.values {
                        guard !participants.isEmpty else { continue }

                        if let participant = participants.first(where: { $0.identity == spaceView.oneToOneIdentity }) {
                            return Contact(
                                identity: participant.identity,
                                name: participant.title,
                                globalName: participant.displayGlobalName,
                                icon: participant.icon
                            )
                        }
                        break
                    }
                    return nil
                }
            }

            var results: [Contact] = []
            for await contact in group {
                if let contact {
                    results.append(contact)
                }
            }
            return results
        }

        return contacts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
