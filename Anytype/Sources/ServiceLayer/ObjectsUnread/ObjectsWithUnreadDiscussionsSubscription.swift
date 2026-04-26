import Foundation
import Services
import AsyncTools
import AsyncAlgorithms
@preconcurrency import Combine

protocol ObjectsWithUnreadDiscussionsSubscriptionProtocol: AnyObject, Sendable {
    func entries() async -> [ParentObjectUnreadEntry]
    var entriesSequence: AnyAsyncSequence<[ParentObjectUnreadEntry]> { get async }
    func startSubscription() async
    func stopSubscription() async
}

actor ObjectsWithUnreadDiscussionsSubscription: ObjectsWithUnreadDiscussionsSubscriptionProtocol {


    // MARK: - ok
    private let subscriptionBuilder: any ObjectsWithUnreadDiscussionsSubscriptionBuilderProtocol = ObjectsWithUnreadDiscussionsSubscriptionBuilder()
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()

    
    private let participantsStorage: any ParticipantsStorageProtocol = Container.shared.participantsStorage()

    
    
    // MARK: - test
    
    private var participantsTask: Task<Void, Never>?
    
    // MARK: - generated
    
    private let spaceViewsStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()
    private let primaryStorage: any SubscriptionStorageProtocol
    private let secondaryStorage: any SubscriptionStorageProtocol

    private let entriesStream = AsyncToManyStream<[ParentObjectUnreadEntry]>()
    private var combineTask: Task<Void, Never>?
    private var lastAppliedParentIds: Set<String> = []
    private var lastAppliedParticipantIds: Set<String> = []

    init() {
        self.primaryStorage = subscriptionStorageProvider.createSubscriptionStorage(
            subId: subscriptionBuilder.primarySubscriptionId
        )
        // Why do we need this secondary storage subscription? Maybe we can build Subscription which will get list of object with layout discussion which will have unread unreads and
        // or maybe we just need to maybe we just don't need to subscribe to discussion objects and trying to get parent details from discussion object maybe we will subscribe for objects across all spaces which have discussion ID. And then search for discussions Which has unread counters or are unread mentions. 
        self.secondaryStorage = subscriptionStorageProvider.createSubscriptionStorage(
            subId: subscriptionBuilder.secondarySubscriptionId
        )
    }

    func entries() -> [ParentObjectUnreadEntry] {
        entriesStream.value ?? []
    }

    var entriesSequence: AnyAsyncSequence<[ParentObjectUnreadEntry]> {
        entriesStream.eraseToAnyAsyncSequence()
    }

    func startSubscription() async {
        
        let initialIds = Set(participantsStorage.participants.map(\.id))
        
        // We should subscribe for participants sequence because if we access participant storage synchronously it returns new or empty array of participants
        participantsTask = Task {
            for await participants in participantsStorage.participantsSequence {
                debugPrint("debuuug \(participants)")
            }
        }
        
        
        
        let data = subscriptionBuilder.build(myParticipantIds: Array(initialIds))
        try? await primaryStorage.startOrUpdateSubscription(data: data, update: { state in
            debugPrint("debuuug \(state)")
        })
        
//        guard combineTask == nil else { return }

//        let initialIds = Set(participantsStorage.participants.map(\.id))
//        try? await primaryStorage.startOrUpdateSubscription(
//            data: subscriptionBuilder.build(myParticipantIds: Array(initialIds))
//        )
//        lastAppliedParticipantIds = initialIds
//
//        // Start the secondary subscription with an empty id set so its publisher emits a first
//        // value immediately. combineLatest then fires as soon as primary returns; handleEmission
//        // updates the secondary id set with the actual backlinks.
//        try? await secondaryStorage.startOrUpdateSubscription(
//            data: subscriptionBuilder.buildSecondary(parentIds: [])
//        )
//        lastAppliedParentIds = []
//
//        let primaryStream = primaryStorage.statePublisher.values.map(\.items)
//        let secondaryStream = secondaryStorage.statePublisher.values.map(\.items)
//        let participantsStream = participantsStorage.participantsSequence
//
//        combineTask = Task { [weak self] in
//            for await (primary, secondary, participants) in combineLatest(
//                primaryStream,
//                secondaryStream,
//                participantsStream
//            ) {
//                await self?.handleEmission(primary: primary, secondary: secondary, participants: participants)
//            }
//        }
    }

    func stopSubscription() async {
        combineTask?.cancel()
        combineTask = nil
        try? await primaryStorage.stopSubscription()
        try? await secondaryStorage.stopSubscription()
        lastAppliedParticipantIds = []
        lastAppliedParentIds = []
        entriesStream.clearLastValue()
    }

    // MARK: - Private

    private func handleEmission(
        primary: [ObjectDetails],
        secondary: [ObjectDetails],
        participants: [Participant]
    ) async {
        let myParticipantIds = Set(participants.map(\.id))
        if myParticipantIds != lastAppliedParticipantIds {
            try? await primaryStorage.startOrUpdateSubscription(
                data: subscriptionBuilder.build(myParticipantIds: Array(myParticipantIds))
            )
            lastAppliedParticipantIds = myParticipantIds
        }

        let parentIds = Set(primary.flatMap(\.backlinks))
        if parentIds != lastAppliedParentIds {
            try? await secondaryStorage.startOrUpdateSubscription(
                data: subscriptionBuilder.buildSecondary(parentIds: Array(parentIds))
            )
            lastAppliedParentIds = parentIds
        }

        let participantsBySpaceId = Dictionary(uniqueKeysWithValues: participants.map { ($0.spaceId, $0.id) })
        var entries: [ParentObjectUnreadEntry] = []
        for discussion in primary {
            guard let parent = secondary.first(where: { $0.discussionId == discussion.id }) else { continue }
            let myParticipantId = participantsBySpaceId[parent.spaceId]
            let spaceMuted = spaceViewsStorage.spaceView(spaceId: parent.spaceId)?.pushNotificationMode == .nothing
            if let entry = ParentObjectUnreadEntryBuilder.makeEntry(
                discussion: discussion,
                parent: parent,
                myParticipantId: myParticipantId,
                spaceMuted: spaceMuted
            ) {
                entries.append(entry)
            }
        }
        entriesStream.send(entries)
    }
}

extension Container {
    var objectsWithUnreadDiscussionsSubscription: Factory<any ObjectsWithUnreadDiscussionsSubscriptionProtocol> {
        self { ObjectsWithUnreadDiscussionsSubscription() }.singleton
    }
}
