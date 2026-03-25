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

        var contacts: [Contact] = []

        for spaceView in oneToOneSpaces {
            let subscription = participantSubscriptionProvider.subscription(spaceId: spaceView.targetSpaceId)

            for await participants in subscription.participantsPublisher.values {
                guard !participants.isEmpty else { continue }

                if let participant = participants.first(where: { $0.identity == spaceView.oneToOneIdentity }) {
                    let contact = Contact(
                        identity: participant.identity,
                        name: participant.title,
                        globalName: participant.displayGlobalName,
                        icon: participant.icon
                    )
                    contacts.append(contact)
                }
                break
            }
        }

        return contacts
    }
}
