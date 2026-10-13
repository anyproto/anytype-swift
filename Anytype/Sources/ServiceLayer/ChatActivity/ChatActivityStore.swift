import Foundation
import Combine
import Services
import AnytypeCore
import ProtobufMessages

@MainActor
protocol ChatActivityStoreProtocol: AnyObject {
    /// The per-device "Show others when I'm typing" setting.
    var sendTypingEnabled: Bool { get }
    func setSendTypingEnabled(_ enabled: Bool)

    /// Starts collecting activity for a chat or discussion on screen. Refcounted; nil when the feature is off.
    func attach(spaceId: String, chatId: String, mode: ChatActivityMode) -> ChatActivityState?
    func detach(_ state: ChatActivityState)
    /// Chats: the newest message from the message store, nil for an empty chat.
    func observeTail(_ message: ActivityObservedMessage?, in state: ChatActivityState)

    func registerTypingPublisher(_ publisher: ChatTypingPublisher)
    func publishTyping(spaceId: String, objectId: String, signal: TypingSignal)

    /// Logout and account switch.
    func clearAll()
}

/// Owns live activity for the app session: subscribes `typing/<id>` and `status/<id>` while a
/// chat or discussion is on screen, feeds the pure journal and roster, and projects them into
/// observable state. Pubsub commands run through one serial queue so a goodbye never overtakes
/// the state it ends, and an unsubscribe never overtakes a subscribe.
@MainActor
final class ChatActivityStore: ChatActivityStoreProtocol, SceneStateListener {

    private enum Event: Sendable {
        case pubsub(spaceId: String, topic: String, payload: Data, identity: String)
        case messageAdded(chatId: String, message: ActivityObservedMessage)
        case messageDeleted(chatId: String, messageId: String)
    }

    private enum Command: Sendable {
        case subscribe(spaceId: String, topics: [String], subId: String)
        case unsubscribe(subId: String)
        case publish(spaceId: String, topic: String, payload: Data)
    }

    private static let sweepInterval: Duration = .seconds(1)

    private let pubsubService: any PubsubServiceProtocol = Container.shared.pubsubService()
    private let accountManager: any AccountManagerProtocol = Container.shared.accountManager()
    private let userDefaults: any UserDefaultsStorageProtocol = Container.shared.userDefaultsStorage()
    private let participantSpacesStorage: any ParticipantSpacesStorageProtocol = Container.shared.participantSpacesStorage()

    private var journals: [ChatActivityScope: ChatActivityJournal] = [:]
    private var rosters: [ChatActivityScope: TypingRoster] = [:]
    private var states: [ChatActivityScope: ChatActivityState] = [:]
    private var attachCounts: [ChatActivityScope: Int] = [:]
    /// Runs whose freshness may still flip, re-projected on each sweep.
    private var liveRuns: [ChatActivityScope: Set<String>] = [:]
    private var typingPublishers: [Weak<ChatTypingPublisher>] = []

    private let commandStream: AsyncStream<Command>
    private let commands: AsyncStream<Command>.Continuation
    private var commandTask: Task<Void, Never>?
    private var eventRegistration: Task<Void, Never>?
    private var eventSubscription: AnyCancellable?
    private var eventTask: Task<Void, Never>?
    private var sweepTask: Task<Void, Never>?
    private var spacesTask: Task<Void, Never>?
    /// Spaces the account can still open; nil until the first list arrives.
    private var activeSpaceIds: Set<String>?

    nonisolated init() {
        let (stream, continuation) = AsyncStream.makeStream(of: Command.self)
        commandStream = stream
        commands = continuation
    }

    // MARK: - ChatActivityStoreProtocol

    var sendTypingEnabled: Bool {
        userDefaults.sendTypingIndicator
    }

    func setSendTypingEnabled(_ enabled: Bool) {
        userDefaults.sendTypingIndicator = enabled
        typingPublishers.forEach { $0.value?.settingChanged() }
    }

    func attach(spaceId: String, chatId: String, mode: ChatActivityMode) -> ChatActivityState? {
        let accountId = accountManager.account.id
        guard FeatureFlags.chatActivity, accountId.isNotEmpty else { return nil }
        startIfNeeded()

        let scope = ChatActivityScope(accountId: accountId, spaceId: spaceId, chatId: chatId)
        let count = attachCounts[scope] ?? 0
        attachCounts[scope] = count + 1
        if journals[scope] == nil {
            journals[scope] = ChatActivityJournal(mode: mode)
        }
        let state = states[scope] ?? ChatActivityState(scope: scope, mode: mode)
        states[scope] = state

        if count == 0 {
            // Subscribe before announcing ourselves; others show up on their next refresh
            commands.yield(.subscribe(spaceId: spaceId, topics: Self.topics(chatId: chatId), subId: Self.subId(chatId: chatId)))
            startSweepIfNeeded()
        }
        projectAll(scope: scope, now: Date())
        return state
    }

    func detach(_ state: ChatActivityState) {
        let scope = state.scope
        guard let count = attachCounts[scope] else { return }
        guard count <= 1 else {
            attachCounts[scope] = count - 1
            return
        }
        attachCounts[scope] = nil
        commands.yield(.unsubscribe(subId: Self.subId(chatId: scope.chatId)))
        // Run history stays for the session; typing and transient status are live-only.
        // Live runs stay listed so a quick return still ages their dots.
        journals[scope]?.markDetached()
        rosters[scope] = nil
        state.setTypers([])
        state.setStatuses([])
        if let activeSpaceIds, !activeSpaceIds.contains(scope.spaceId) {
            drop(scope: scope)
        }
    }

    func observeTail(_ message: ActivityObservedMessage?, in state: ChatActivityState) {
        let scope = state.scope
        guard attachCounts[scope] != nil, var journal = journals[scope] else { return }
        let update = journal.observeTail(message)
        journals[scope] = journal
        apply(update, scope: scope, now: Date())
    }

    func registerTypingPublisher(_ publisher: ChatTypingPublisher) {
        typingPublishers.removeAll { $0.value == nil }
        typingPublishers.append(Weak(value: publisher))
    }

    func publishTyping(spaceId: String, objectId: String, signal: TypingSignal) {
        let payload = ChatTypingPayload(sessionId: ChatActivitySession.id, active: signal.active, replyTo: signal.replyTo)
        commands.yield(.publish(spaceId: spaceId, topic: ChatActivityTopic.typing(objectId: objectId), payload: payload.encoded()))
    }

    func clearAll() {
        // Owed goodbyes go out before the unsubscribes
        typingPublishers.forEach { $0.value?.stop() }
        for scope in attachCounts.keys {
            commands.yield(.unsubscribe(subId: Self.subId(chatId: scope.chatId)))
        }
        attachCounts.removeAll()
        journals.removeAll()
        rosters.removeAll()
        liveRuns.removeAll()
        states.removeAll()
        sweepTask?.cancel()
        sweepTask = nil
    }

    // MARK: - SceneStateListener

    func willEnterForeground() {
        // Re-assert interest after suspension; reusing a subId replaces its topic set, so this is idempotent
        for scope in attachCounts.keys {
            commands.yield(.subscribe(spaceId: scope.spaceId, topics: Self.topics(chatId: scope.chatId), subId: Self.subId(chatId: scope.chatId)))
        }
    }

    func didEnterBackground() {
        typingPublishers.forEach { $0.value?.stop() }
    }

    // MARK: - Private: setup

    private static func subId(chatId: String) -> String {
        "activity-\(ChatActivitySession.id)-\(chatId)"
    }

    private static func topics(chatId: String) -> [String] {
        [ChatActivityTopic.typing(objectId: chatId), ChatActivityTopic.status(chatId: chatId)]
    }

    private func startIfNeeded() {
        guard eventRegistration == nil else { return }

        Container.shared.sceneStateNotifier().addListener(self)

        let (stream, continuation) = AsyncStream.makeStream(of: Event.self)
        // Runs on the event bus for every bunch: keep it to a cheap filter and hand off in order
        let handler: @Sendable (EventsBunch) async -> Void = { events in
            for event in events.middlewareEvents {
                switch event.value {
                case .pubsubMessage(let message):
                    continuation.yield(.pubsub(spaceId: event.spaceID, topic: message.topic, payload: message.payload, identity: message.identity))
                case .chatAdd(let data):
                    let observed = ActivityObservedMessage(id: data.message.id, orderId: data.message.orderID, creator: data.message.creator)
                    continuation.yield(.messageAdded(chatId: events.contextId, message: observed))
                case .chatDelete(let data):
                    continuation.yield(.messageDeleted(chatId: events.contextId, messageId: data.id))
                default:
                    break
                }
            }
        }
        let registration = Task { [weak self] in
            let subscription = await EventBunchSubscribtion.default.addHandlerAwaiting(handler)
            self?.eventSubscription = subscription
        }
        eventRegistration = registration
        // Subscribe only once received messages have somewhere to go
        startCommands(after: registration)

        eventTask = Task { [weak self] in
            for await event in stream {
                self?.handle(event)
            }
        }

        spacesTask = Task { [weak self, participantSpacesStorage] in
            let spaceIdsSequence = participantSpacesStorage.activeParticipantSpacesPublisher
                .map { Set($0.map(\.spaceView.targetSpaceId)) }
                .removeDuplicates()
                .values
            for await spaceIds in spaceIdsSequence {
                self?.dropScopes(outside: spaceIds)
            }
        }
    }

    private func startCommands(after registration: Task<Void, Never>) {
        guard commandTask == nil else { return }
        let stream = commandStream
        let pubsubService = pubsubService
        commandTask = Task.detached(priority: .utility) {
            await registration.value
            for await command in stream {
                // Ephemeral signals: drop on failure, the next refresh repairs state
                switch command {
                case let .subscribe(spaceId, topics, subId):
                    try? await pubsubService.subscribe(spaceId: spaceId, topics: topics, subId: subId)
                case let .unsubscribe(subId):
                    try? await pubsubService.unsubscribe(subId: subId)
                case let .publish(spaceId, topic, payload):
                    try? await pubsubService.publish(spaceId: spaceId, topic: topic, payload: payload)
                }
            }
        }
    }

    private func startSweepIfNeeded() {
        guard sweepTask == nil else { return }
        sweepTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: Self.sweepInterval)
                guard let self, self.sweep() else { return }
            }
        }
    }

    /// Losing access to a space clears what was collected there. A chat still on screen is
    /// cleared when it detaches.
    private func dropScopes(outside spaceIds: Set<String>) {
        // An empty list is the storage still loading, not every space lost
        guard spaceIds.isNotEmpty else { return }
        activeSpaceIds = spaceIds
        let lost = journals.keys.filter { !spaceIds.contains($0.spaceId) && attachCounts[$0] == nil }
        lost.forEach { drop(scope: $0) }
    }

    private func drop(scope: ChatActivityScope) {
        journals[scope] = nil
        rosters[scope] = nil
        liveRuns[scope] = nil
        states[scope] = nil
    }

    // MARK: - Private: events

    private func handle(_ event: Event) {
        let now = Date()
        switch event {
        case let .pubsub(spaceId, topic, payload, identity):
            switch ChatActivityTopic.parse(topic) {
            case .typing(let objectId):
                guard let payload = ChatTypingPayload.decode(payload) else { return }
                for scope in attachedScopes(chatId: objectId, spaceId: spaceId) {
                    var roster = rosters[scope] ?? TypingRoster()
                    let changed = roster.apply(
                        payload,
                        identity: identity,
                        ownSessionId: ChatActivitySession.id,
                        ownIdentity: accountManager.account.id,
                        now: now
                    )
                    rosters[scope] = roster
                    if changed {
                        projectTypers(scope: scope, now: now)
                    }
                }
            case .status(let chatId):
                // Status is never filtered by account: an agent may run under the user's own identity
                guard let payload = ChatStatusPayload.decode(payload) else { return }
                for scope in attachedScopes(chatId: chatId, spaceId: spaceId) {
                    guard var journal = journals[scope] else { continue }
                    let update = journal.applyStatus(payload, publisher: identity, now: now)
                    journals[scope] = journal
                    liveRuns[scope, default: []].formUnion(update.runIds)
                    apply(update, scope: scope, now: now)
                    // Fresh agent activity hides that sender's typing
                    projectTypers(scope: scope, now: now)
                }
            case nil:
                return
            }
        case let .messageAdded(chatId, message):
            for scope in attachedScopes(chatId: chatId, spaceId: nil) {
                guard var journal = journals[scope] else { continue }
                let update = journal.observeMessage(message)
                journals[scope] = journal
                // Duplicates (another subscription's copy of the same message) change nothing
                if update.isNewMessage {
                    clearTyping(identity: message.creator, scope: scope)
                }
                apply(update, scope: scope, now: now)
            }
        case let .messageDeleted(chatId, messageId):
            for scope in attachedScopes(chatId: chatId, spaceId: nil) {
                guard var journal = journals[scope] else { continue }
                let update = journal.observeMessageDeleted(id: messageId)
                journals[scope] = journal
                apply(update, scope: scope, now: now)
            }
        }
    }

    private func attachedScopes(chatId: String, spaceId: String?) -> [ChatActivityScope] {
        attachCounts.keys.filter { scope in
            scope.chatId == chatId && (spaceId.map { $0.isEmpty || $0 == scope.spaceId } ?? true)
        }
    }

    private func clearTyping(identity: String, scope: ChatActivityScope) {
        guard var roster = rosters[scope], roster.clear(identity: identity) else { return }
        rosters[scope] = roster
        projectTypers(scope: scope, now: Date())
    }

    /// Returns false once nothing is attached, which ends the sweep loop.
    private func sweep() -> Bool {
        let attached = Array(attachCounts.keys)
        guard attached.isNotEmpty else {
            sweepTask = nil
            return false
        }
        let now = Date()
        for scope in attached {
            if var roster = rosters[scope], roster.sweep(now: now) {
                rosters[scope] = roster
            }
            if var journal = journals[scope], journal.sweep(now: now) {
                journals[scope] = journal
                projectStatuses(scope: scope)
            }
            projectLiveRuns(scope: scope, now: now)
            projectTypers(scope: scope, now: now)
        }
        return true
    }

    // MARK: - Private: projection

    private func apply(_ update: ChatActivityJournalUpdate, scope: ChatActivityScope, now: Date) {
        guard !update.isEmpty else { return }
        if update.transientChanged {
            projectStatuses(scope: scope)
        }
        for runId in update.runIds {
            projectRun(runId: runId, scope: scope, now: now)
        }
        // Content heartbeats never touch placement
        if update.layoutChanged {
            projectLayout(scope: scope)
        }
    }

    private func projectAll(scope: ChatActivityScope, now: Date) {
        guard let journal = journals[scope] else { return }
        for run in journal.runs {
            projectRun(runId: run.id, scope: scope, now: now)
        }
        projectLayout(scope: scope)
        projectStatuses(scope: scope)
        projectTypers(scope: scope, now: now)
    }

    private func projectLayout(scope: ChatActivityScope) {
        guard let journal = journals[scope], let state = states[scope] else { return }
        state.setLayout(ChatActivityLayout(
            runs: journal.runs.map {
                ActivityRunLayout(
                    id: $0.id,
                    publishers: $0.publishers,
                    replyTo: $0.replyTo,
                    anchorMessageId: $0.anchor?.id,
                    isOpen: $0.isOpen,
                    closedByMessageId: $0.closedByMessageId
                )
            },
            tailKnown: journal.tailKnown,
            tailMessageId: journal.tail?.id,
            deletedMessageIds: journal.deletedMessageIds
        ))
    }

    private func projectStatuses(scope: ChatActivityScope) {
        guard let journal = journals[scope], let state = states[scope] else { return }
        state.setStatuses(journal.transient.map {
            ActivityStatusLine(publisher: $0.publisher, text: $0.text, replyTo: $0.replyTo)
        })
    }

    private func projectRun(runId: String, scope: ChatActivityScope, now: Date) {
        guard let journal = journals[scope], let state = states[scope],
              let summary = journal.summary(runId: runId, now: now) else { return }
        let items = journal.items(inRun: runId).map { ActivityItemSnapshot(item: $0, now: now) }
        state.updateRun(id: runId, summary: summary, items: items)
    }

    /// Freshness flips with time alone (running → stale after 10 s), so recently updated runs are
    /// re-projected until they go quiet.
    private func projectLiveRuns(scope: ChatActivityScope, now: Date) {
        guard let runIds = liveRuns[scope], runIds.isNotEmpty, let journal = journals[scope] else { return }
        var stillLive = Set<String>()
        for runId in runIds {
            projectRun(runId: runId, scope: scope, now: now)
            let lastSeen = journal.items(inRun: runId).map(\.lastSeenAt).max()
            if let lastSeen, now.timeIntervalSince(lastSeen) <= ChatActivityJournal.freshness + 1 {
                stillLive.insert(runId)
            }
        }
        liveRuns[scope] = stillLive
    }

    private func projectTypers(scope: ChatActivityScope, now: Date) {
        guard let state = states[scope] else { return }
        let journal = journals[scope]
        let typers = (rosters[scope]?.typers() ?? []).filter {
            // The richer row wins: a sender with fresh agent activity gets no typing row
            !(journal?.hasFreshActivity(publisher: $0.identity, now: now) ?? false)
        }
        state.setTypers(typers)
    }
}
