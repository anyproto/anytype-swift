import Foundation
import Services
import AsyncTools
import AsyncAlgorithms

// All participants (members) across all spaces, filled by one vault-wide
// subscription - the deps source for person chips, creator-token resolution and
// message-author attribution. Never fetch participants per space or per row.
protocol CrossSpaceParticipantsStorageProtocol: AnyObject, Sendable {
    var allParticipantsSequence: AnyAsyncSequence<[Participant]> { get async }
    func startSubscription() async
    func stopSubscription() async
}

actor CrossSpaceParticipantsStorage: CrossSpaceParticipantsStorageProtocol {

    private let subscriptionBuilder: any CrossSpaceParticipantsSubscriptionBuilderProtocol = Container.shared.crossSpaceParticipantsSubscriptionBuilder()
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()
    private let subscriptionStorage: any SubscriptionStorageProtocol

    private let allParticipantsStream = AsyncToManyStream<[Participant]>()

    var allParticipantsSequence: AnyAsyncSequence<[Participant]> {
        allParticipantsStream
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
            self.allParticipantsStream.send(data.items.compactMap { try? Participant(details: $0) })
        }
    }

    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
