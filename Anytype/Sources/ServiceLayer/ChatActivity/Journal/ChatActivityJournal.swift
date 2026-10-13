import Foundation
import AnytypeCore

enum ChatActivityMode: Sendable {
    /// Space chat: one open run per chat, closed by the next message from anyone.
    case chat
    /// Object discussion: one open run per sender, closed only by that sender's own comment.
    case discussion
}

enum ActivityLifecycle: String, Sendable {
    case inProgress = "in_progress"
    case complete
    case error

    var isTerminal: Bool {
        self != .inProgress
    }
}

struct ActivityMessageRef: Equatable, Hashable, Sendable {
    let id: String
    let orderId: String
}

struct ActivityObservedMessage: Equatable, Sendable {
    let id: String
    let orderId: String
    let creator: String

    var ref: ActivityMessageRef {
        ActivityMessageRef(id: id, orderId: orderId)
    }
}

struct ActivityItem: Identifiable, Equatable, Sendable {
    let id: String
    /// Nil for generic data items.
    let toolCallId: String?
    let publisher: String
    let runId: String
    let order: Int
    /// The latest event's text; nil shows the localized default.
    var text: String?
    /// Merged `data`; for tool calls always an object.
    var data: ActivityJSON
    /// Nil until a valid status arrives: no badge.
    var lifecycle: ActivityLifecycle?
    var lastSeenAt: Date

    var isToolCall: Bool {
        toolCallId != nil
    }

    var toolName: String? {
        data["tool_name"]?.nonEmptyString
    }

    func isFresh(now: Date) -> Bool {
        now.timeIntervalSince(lastSeenAt) < ChatActivityJournal.freshness
    }
}

struct ActivityRun: Identifiable, Equatable, Sendable {
    let id: String
    let order: Int
    /// Publishers in first-seen order. A discussion run has exactly one.
    var publishers: [String]
    /// Discussions: the `reply_to` of the event that opened the run.
    let replyTo: String?
    /// Chats: the tail message when the run opened.
    let anchor: ActivityMessageRef?
    /// Discussions: the newest message order seen when the run opened. Older messages never close it.
    let openedAfterOrderId: String?
    var isOpen: Bool
    /// The message that closed the run. Nil while open, and when closed without one
    /// (a `reply_to` change or a gap in observation).
    var closedByMessageId: String?
    var itemIds: [String]
    var latestItemId: String?
}

struct ActivityTransientStatus: Equatable, Sendable {
    let publisher: String
    var text: String?
    var replyTo: String?
    var receivedAt: Date
}

enum ActivityRunState: Equatable, Sendable {
    /// Something runs and was updated within 10 s: animated dots.
    case running
    /// A running call went quiet: no dots; the sheet says "No recent updates", never "Failed".
    case stale
    /// Every tool call succeeded: a check.
    case completed
    /// At least one call failed: an error mark that stays visible.
    case failed
    /// Nothing to report.
    case idle
}

struct ActivityRunSummary: Equatable, Sendable {
    let publishers: [String]
    let toolCallCount: Int
    let itemCount: Int
    let runningCount: Int
    let failedCount: Int
    let latestText: String?
    let state: ActivityRunState

    var isToolCallsOnly: Bool {
        toolCallCount == itemCount
    }
}

struct ChatActivityJournalUpdate: Equatable, Sendable {
    /// Runs opened, closed or regrouped, or the chat tail became known: placement may change.
    var layoutChanged = false
    var transientChanged = false
    /// Runs whose content changed.
    var runIds: Set<String> = []
    /// A message not seen before arrived: its author's typing ends.
    var isNewMessage = false

    var isEmpty: Bool {
        !layoutChanged && !transientChanged && runIds.isEmpty
    }

    mutating func formUnion(_ other: ChatActivityJournalUpdate) {
        layoutChanged = layoutChanged || other.layoutChanged
        transientChanged = transientChanged || other.transientChanged
        runIds.formUnion(other.runIds)
        isNewMessage = isNewMessage || other.isNewMessage
    }
}

/// Agent activity received on `status/<chatId>` for one chat or discussion, for the app session.
/// Pure: the caller supplies the clock.
///
/// - Text-only status is a transient line per sender: expires 10 s after receipt, cleared by a
///   message from that sender, never retained.
/// - One item per `(sender, tool_call_id)`. A known id updates its item in place: top-level `data`
///   fields merge shallowly and lifecycle only moves forward.
/// - Other data becomes a generic item; consecutive equal snapshots from one sender count once.
/// - Items group into runs. Messages close runs (chat: any message; discussion: the sender's own
///   comment) but never complete or fail calls.
struct ChatActivityJournal {

    static let freshness: TimeInterval = 10

    let mode: ChatActivityMode

    private(set) var runs: [ActivityRun] = []
    private(set) var items: [String: ActivityItem] = [:]
    private(set) var transient: [ActivityTransientStatus] = []
    private(set) var deletedMessageIds: Set<String> = []
    /// Chats: the newest message known; nil while the chat is empty.
    private(set) var tail: ActivityMessageRef?

    private struct CallKey: Hashable {
        let publisher: String
        let toolCallId: String
    }

    private struct GenericBaseline {
        let fingerprint: String
        let itemId: String?
    }

    private var runIndex: [String: Int] = [:]
    private var callIndex: [CallKey: String] = [:]
    private var openChatRunId: String?
    private var openRunByPublisher: [String: String] = [:]
    private(set) var tailKnown = false
    private var awaitingTailAfterGap = false
    /// The run open when the screen stopped collecting; closed once a gap is confirmed.
    private var gapRunId: String?
    private var maxSeenOrderId: String?
    private var seenMessageIds: Set<String> = []
    private var genericBaseline: [String: GenericBaseline] = [:]
    private var lastActivityAt: [String: Date] = [:]
    private var nextOrder = 0

    init(mode: ChatActivityMode) {
        self.mode = mode
    }

    // MARK: - Inputs

    mutating func applyStatus(_ payload: ChatStatusPayload, publisher: String, now: Date) -> ChatActivityJournalUpdate {
        guard let data = payload.retainedData else {
            return applyTransient(payload, publisher: publisher, now: now)
        }
        if let toolCallId = payload.toolCallId {
            return applyToolCall(toolCallId: toolCallId, data: data, payload: payload, publisher: publisher, now: now)
        }
        return applyGeneric(data: data, payload: payload, publisher: publisher, now: now)
    }

    /// Chats: the newest message from the message store. It sets the tail once, and after
    /// `markDetached()` reconciles it: a moved tail means messages may have been missed, so the run
    /// that was open closes without a message. Otherwise snapshots are ignored: only live messages,
    /// in event order, close runs.
    mutating func observeTail(_ message: ActivityObservedMessage?) -> ChatActivityJournalUpdate {
        guard mode == .chat else { return ChatActivityJournalUpdate() }
        guard tailKnown else {
            tailKnown = true
            if let message {
                tail = message.ref
                remember(message)
            }
            // Runs that arrived before the tail can now be placed
            return ChatActivityJournalUpdate(layoutChanged: true)
        }
        guard awaitingTailAfterGap else { return ChatActivityJournalUpdate() }
        awaitingTailAfterGap = false
        guard let message, message.ref != tail else {
            gapRunId = nil
            return ChatActivityJournalUpdate()
        }
        remember(message)
        var update = closeGapRun()
        tail = message.ref
        genericBaseline.removeAll()
        update.layoutChanged = true
        return update
    }

    /// A live message added to the chat, in event order.
    mutating func observeMessage(_ message: ActivityObservedMessage) -> ChatActivityJournalUpdate {
        guard seenMessageIds.insert(message.id).inserted else { return ChatActivityJournalUpdate() }
        if maxSeenOrderId.map({ message.orderId > $0 }) ?? true {
            maxSeenOrderId = message.orderId
        }

        var update = ChatActivityJournalUpdate(isNewMessage: true)
        // A message from the sender ends its transient status and its claim to fresh activity
        lastActivityAt[message.creator] = nil
        if transient.contains(where: { $0.publisher == message.creator }) {
            transient.removeAll { $0.publisher == message.creator }
            update.transientChanged = true
        }

        switch mode {
        case .chat:
            if awaitingTailAfterGap {
                // Messages were missed while away: the run open then can't be placed by them
                awaitingTailAfterGap = false
                update.formUnion(closeGapRun())
            }
            // History inserts at or before the known tail are not boundaries
            guard tail.map({ message.orderId > $0.orderId }) ?? true else { return update }
            tail = message.ref
            tailKnown = true
            genericBaseline.removeAll()
            if let runId = openChatRunId {
                close(runId: runId, by: message.id)
                update.layoutChanged = true
                update.runIds.insert(runId)
            }
            openChatRunId = nil
        case .discussion:
            guard let runId = openRunByPublisher[message.creator], let openRun = run(id: runId) else { return update }
            if let openedAfter = openRun.openedAfterOrderId, message.orderId <= openedAfter {
                return update
            }
            close(runId: runId, by: message.id)
            openRunByPublisher[message.creator] = nil
            genericBaseline[message.creator] = nil
            update.layoutChanged = true
            update.runIds.insert(runId)
        }
        return update
    }

    mutating func observeMessageDeleted(id: String) -> ChatActivityJournalUpdate {
        guard deletedMessageIds.insert(id).inserted else { return ChatActivityJournalUpdate() }
        var update = ChatActivityJournalUpdate()
        if runs.contains(where: { $0.closedByMessageId == id }) {
            update.layoutChanged = true
        }
        return update
    }

    /// The screen stopped collecting. Transient statuses are live-only and go; on return, a moved
    /// tail means messages may have been missed.
    mutating func markDetached() {
        transient.removeAll()
        if mode == .chat, tailKnown {
            awaitingTailAfterGap = true
            gapRunId = openChatRunId
        }
    }

    /// Drops expired transient statuses. Returns true when any expired.
    mutating func sweep(now: Date) -> Bool {
        let count = transient.count
        transient.removeAll { now.timeIntervalSince($0.receivedAt) >= Self.freshness }
        return transient.count != count
    }

    // MARK: - Queries

    func run(id: String) -> ActivityRun? {
        runIndex[id].map { runs[$0] }
    }

    func items(inRun runId: String) -> [ActivityItem] {
        run(id: runId)?.itemIds.compactMap { items[$0] } ?? []
    }

    func hasFreshActivity(publisher: String, now: Date) -> Bool {
        guard let last = lastActivityAt[publisher] else { return false }
        return now.timeIntervalSince(last) < Self.freshness
    }

    func summary(runId: String, now: Date) -> ActivityRunSummary? {
        guard let summarized = run(id: runId) else { return nil }
        let runItems = summarized.itemIds.compactMap { items[$0] }

        var toolCallCount = 0
        var runningCount = 0
        var failedCount = 0
        var hasFreshActive = false
        var hasStaleRunning = false
        var allToolCallsComplete = true

        for item in runItems {
            if item.isToolCall {
                toolCallCount += 1
                if item.lifecycle != .complete {
                    allToolCallsComplete = false
                }
            }
            switch item.lifecycle {
            case .inProgress:
                runningCount += 1
                if item.isFresh(now: now) {
                    hasFreshActive = true
                } else {
                    hasStaleRunning = true
                }
            case .error:
                failedCount += 1
            case .complete:
                break
            case nil:
                if item.isFresh(now: now) {
                    hasFreshActive = true
                }
            }
        }

        let state: ActivityRunState
        if failedCount > 0 {
            state = .failed
        } else if hasFreshActive {
            state = .running
        } else if hasStaleRunning {
            state = .stale
        } else if toolCallCount > 0, allToolCallsComplete {
            state = .completed
        } else {
            state = .idle
        }

        return ActivityRunSummary(
            publishers: summarized.publishers,
            toolCallCount: toolCallCount,
            itemCount: runItems.count,
            runningCount: runningCount,
            failedCount: failedCount,
            latestText: summarized.latestItemId.flatMap { items[$0]?.text },
            state: state
        )
    }

    // MARK: - Private

    private mutating func applyTransient(_ payload: ChatStatusPayload, publisher: String, now: Date) -> ChatActivityJournalUpdate {
        lastActivityAt[publisher] = now
        // Text-only snapshots move the generic baseline but are never retained
        genericBaseline[publisher] = GenericBaseline(
            fingerprint: fingerprint(text: payload.text, replyTo: payload.replyTo, data: nil),
            itemId: nil
        )
        let status = ActivityTransientStatus(publisher: publisher, text: payload.text, replyTo: payload.replyTo, receivedAt: now)
        var update = ChatActivityJournalUpdate()
        if let index = transient.firstIndex(where: { $0.publisher == publisher }) {
            update.transientChanged = transient[index].text != status.text || transient[index].replyTo != status.replyTo
            transient[index] = status
        } else {
            transient.append(status)
            update.transientChanged = true
        }
        return update
    }

    private mutating func applyToolCall(
        toolCallId: String,
        data: ActivityJSON,
        payload: ChatStatusPayload,
        publisher: String,
        now: Date
    ) -> ChatActivityJournalUpdate {
        let explicitStatus = data["status"]?.stringValue
        let key = CallKey(publisher: publisher, toolCallId: toolCallId)

        if let itemId = callIndex[key], var item = items[itemId] {
            // Lifecycle only moves forward. Once terminal, an event with a different explicit
            // status (a late in_progress included) is dropped whole.
            if let current = item.lifecycle, current.isTerminal, let explicitStatus, explicitStatus != current.rawValue {
                return ChatActivityJournalUpdate()
            }
            lastActivityAt[publisher] = now
            if item.lifecycle?.isTerminal != true, let lifecycle = explicitStatus.flatMap(ActivityLifecycle.init(rawValue:)) {
                item.lifecycle = lifecycle
            }
            item.data = item.data.mergingTopLevel(data)
            item.text = payload.text
            item.lastSeenAt = now
            items[itemId] = item
            setLatestItem(itemId, inRun: item.runId)
            // A known id never moves and never adds to counts, even in a closed run
            return ChatActivityJournalUpdate(runIds: [item.runId])
        }

        lastActivityAt[publisher] = now
        var update = openRun(for: publisher, replyTo: payload.replyTo)
        guard let runId = runIdForNewItem(publisher: publisher) else { return update }
        let item = ActivityItem(
            id: "item-\(nextOrder)",
            toolCallId: toolCallId,
            publisher: publisher,
            runId: runId,
            order: nextOrder,
            text: payload.text,
            data: data,
            lifecycle: explicitStatus.flatMap(ActivityLifecycle.init(rawValue:)),
            lastSeenAt: now
        )
        nextOrder += 1
        insert(item)
        callIndex[key] = item.id
        update.runIds.insert(runId)
        return update
    }

    private mutating func applyGeneric(
        data: ActivityJSON,
        payload: ChatStatusPayload,
        publisher: String,
        now: Date
    ) -> ChatActivityJournalUpdate {
        lastActivityAt[publisher] = now
        let snapshot = fingerprint(text: payload.text, replyTo: payload.replyTo, data: data)

        if let baseline = genericBaseline[publisher], baseline.fingerprint == snapshot,
           let itemId = baseline.itemId, var item = items[itemId],
           item.isFresh(now: now), run(id: item.runId)?.isOpen == true {
            // Equal heartbeat: refresh freshness; it is again the run's latest activity
            item.lastSeenAt = now
            items[itemId] = item
            setLatestItem(itemId, inRun: item.runId)
            return ChatActivityJournalUpdate(runIds: [item.runId])
        }

        var update = openRun(for: publisher, replyTo: payload.replyTo)
        guard let runId = runIdForNewItem(publisher: publisher) else { return update }
        let item = ActivityItem(
            id: "item-\(nextOrder)",
            toolCallId: nil,
            publisher: publisher,
            runId: runId,
            order: nextOrder,
            text: payload.text,
            data: data,
            lifecycle: nil,
            lastSeenAt: now
        )
        nextOrder += 1
        insert(item)
        genericBaseline[publisher] = GenericBaseline(fingerprint: snapshot, itemId: item.id)
        update.runIds.insert(runId)
        return update
    }

    /// Makes sure the run a new item from `publisher` belongs to is open.
    private mutating func openRun(for publisher: String, replyTo: String?) -> ChatActivityJournalUpdate {
        var update = ChatActivityJournalUpdate()
        switch mode {
        case .chat:
            if awaitingTailAfterGap, gapRunId != nil {
                // New work after returning never joins the run from before the gap
                update.formUnion(closeGapRun())
            }
            if let runId = openChatRunId, let index = runIndex[runId] {
                if !runs[index].publishers.contains(publisher) {
                    runs[index].publishers.append(publisher)
                    update.layoutChanged = true
                }
                return update
            }
            let newRun = makeRun(publisher: publisher, replyTo: nil, anchor: tail, openedAfterOrderId: nil)
            openChatRunId = newRun.id
            update.layoutChanged = true
        case .discussion:
            if let runId = openRunByPublisher[publisher], let openRun = run(id: runId) {
                if openRun.replyTo == replyTo {
                    return update
                }
                // A different thread target closes the run without a comment
                close(runId: runId, by: nil)
                genericBaseline[publisher] = nil
                update.runIds.insert(runId)
            }
            let newRun = makeRun(publisher: publisher, replyTo: replyTo, anchor: nil, openedAfterOrderId: maxSeenOrderId)
            openRunByPublisher[publisher] = newRun.id
            update.layoutChanged = true
        }
        return update
    }

    private func runIdForNewItem(publisher: String) -> String? {
        switch mode {
        case .chat:
            openChatRunId
        case .discussion:
            openRunByPublisher[publisher]
        }
    }

    private mutating func makeRun(
        publisher: String,
        replyTo: String?,
        anchor: ActivityMessageRef?,
        openedAfterOrderId: String?
    ) -> ActivityRun {
        let newRun = ActivityRun(
            id: "run-\(nextOrder)",
            order: nextOrder,
            publishers: [publisher],
            replyTo: replyTo,
            anchor: anchor,
            openedAfterOrderId: openedAfterOrderId,
            isOpen: true,
            closedByMessageId: nil,
            itemIds: [],
            latestItemId: nil
        )
        nextOrder += 1
        runIndex[newRun.id] = runs.count
        runs.append(newRun)
        return newRun
    }

    private mutating func insert(_ item: ActivityItem) {
        items[item.id] = item
        guard let index = runIndex[item.runId] else { return }
        runs[index].itemIds.append(item.id)
        runs[index].latestItemId = item.id
    }

    private mutating func setLatestItem(_ itemId: String, inRun runId: String) {
        guard let index = runIndex[runId] else { return }
        runs[index].latestItemId = itemId
    }

    private mutating func close(runId: String, by messageId: String?) {
        guard let index = runIndex[runId] else { return }
        runs[index].isOpen = false
        runs[index].closedByMessageId = messageId
    }

    /// Closes the run that was open before the screen left, without a message.
    private mutating func closeGapRun() -> ChatActivityJournalUpdate {
        var update = ChatActivityJournalUpdate()
        if let runId = gapRunId, run(id: runId)?.isOpen == true {
            close(runId: runId, by: nil)
            if openChatRunId == runId {
                openChatRunId = nil
            }
            update.layoutChanged = true
            update.runIds.insert(runId)
        }
        gapRunId = nil
        return update
    }

    private mutating func remember(_ message: ActivityObservedMessage) {
        seenMessageIds.insert(message.id)
        if maxSeenOrderId.map({ message.orderId > $0 }) ?? true {
            maxSeenOrderId = message.orderId
        }
    }

    private func fingerprint(text: String?, replyTo: String?, data: ActivityJSON?) -> String {
        [
            text ?? "\u{0}",
            replyTo ?? "\u{0}",
            data?.serialized(sortedKeys: true) ?? "\u{0}"
        ].joined(separator: "\u{1}")
    }
}
