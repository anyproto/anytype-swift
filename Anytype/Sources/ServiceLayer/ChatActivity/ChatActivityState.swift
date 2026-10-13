import Foundation
import Observation

struct ChatActivityScope: Hashable, Sendable {
    let accountId: String
    let spaceId: String
    let chatId: String
}

enum ChatActivitySession {
    /// Random per app run: the typing `sessionId` (also the echo filter) and part of subscription ids.
    static let id: String = (0..<8).map { _ in String(format: "%02x", UInt8.random(in: .min ... .max)) }.joined()
}

/// Run fields that decide where a run renders. A change here means a list rebuild.
struct ActivityRunLayout: Identifiable, Equatable, Sendable {
    let id: String
    let publishers: [String]
    let replyTo: String?
    let anchorMessageId: String?
    let isOpen: Bool
    let closedByMessageId: String?
}

struct ChatActivityLayout: Equatable, Sendable {
    var runs: [ActivityRunLayout] = []
    /// False until the first message snapshot: open chat runs render after the tail only once it is known.
    var tailKnown = false
    var tailMessageId: String?
    var deletedMessageIds: Set<String> = []
}

struct ActivityStatusLine: Equatable, Sendable {
    let publisher: String
    let text: String?
    let replyTo: String?
}

struct ActivityItemSnapshot: Identifiable, Equatable, Sendable {
    let id: String
    let publisher: String
    let isToolCall: Bool
    let toolName: String?
    let text: String?
    let lifecycle: ActivityLifecycle?
    let isFresh: Bool
    /// Top-level `data` fields shown as `key: value` rows: all but id, name, status and result.
    let metadata: [ActivityJSONField]
    /// The merged `data`, result included, for "Copy as JSON".
    let data: ActivityJSON

    static let hiddenMetadataKeys: Set<String> = ["tool_call_id", "tool_name", "status", "result"]

    init(item: ActivityItem, now: Date) {
        id = item.id
        publisher = item.publisher
        isToolCall = item.isToolCall
        toolName = item.toolName
        text = item.text
        lifecycle = item.lifecycle
        isFresh = item.isFresh(now: now)
        data = item.data
        if let fields = item.data.fields {
            metadata = fields.filter { !Self.hiddenMetadataKeys.contains($0.key) }
        } else {
            // Arrays and scalars from generic publishers: one row
            metadata = [ActivityJSONField(key: "data", value: item.data)]
        }
    }
}

/// One run, observed by its compact line and its detail sheet. Assigned only on visible change,
/// so status heartbeats don't re-render anything.
@MainActor
@Observable
final class ActivityRunModel: Identifiable {
    let id: String
    private(set) var summary: ActivityRunSummary
    private(set) var items: [ActivityItemSnapshot]

    init(id: String, summary: ActivityRunSummary, items: [ActivityItemSnapshot]) {
        self.id = id
        self.summary = summary
        self.items = items
    }

    func update(summary: ActivityRunSummary, items: [ActivityItemSnapshot]) {
        if self.summary != summary {
            self.summary = summary
        }
        if self.items != items {
            self.items = items
        }
    }
}

struct ChatActivityStateObserver {
    /// Placement inputs changed: runs opened or closed, and in discussions typing or status moved.
    let placementChanged: @MainActor () -> Void
    /// A run's state changed; `from` is `.idle` for a run first seen already finished.
    let runStateChanged: @MainActor (_ run: ActivityRunModel, _ from: ActivityRunState) -> Void
}

/// Live activity of one chat or discussion, kept for the app session.
@MainActor
@Observable
final class ChatActivityState {
    let scope: ChatActivityScope
    let mode: ChatActivityMode

    private(set) var typers: [ChatTypingEntry] = []
    private(set) var statuses: [ActivityStatusLine] = []
    private(set) var layout = ChatActivityLayout()

    @ObservationIgnored
    private var runModels: [String: ActivityRunModel] = [:]
    /// One per screen showing this chat; usually one.
    @ObservationIgnored
    private var observers: [UUID: ChatActivityStateObserver] = [:]

    init(scope: ChatActivityScope, mode: ChatActivityMode) {
        self.scope = scope
        self.mode = mode
    }

    func runModel(id: String) -> ActivityRunModel? {
        runModels[id]
    }

    func addObserver(_ observer: ChatActivityStateObserver) -> UUID {
        let id = UUID()
        observers[id] = observer
        return id
    }

    func removeObserver(_ id: UUID) {
        observers[id] = nil
    }

    func setTypers(_ typers: [ChatTypingEntry]) {
        guard self.typers != typers else { return }
        self.typers = typers
        if mode == .discussion {
            notifyPlacementChanged()
        }
    }

    func setStatuses(_ statuses: [ActivityStatusLine]) {
        guard self.statuses != statuses else { return }
        // A new text for the same sender and thread is a content change, not a placement change
        let movedBetweenThreads = Self.placementKeys(self.statuses) != Self.placementKeys(statuses)
        self.statuses = statuses
        if mode == .discussion, movedBetweenThreads {
            notifyPlacementChanged()
        }
    }

    private static func placementKeys(_ statuses: [ActivityStatusLine]) -> [String] {
        statuses.map { "\($0.publisher)\u{1}\($0.replyTo ?? "")" }
    }

    func setLayout(_ layout: ChatActivityLayout) {
        guard self.layout != layout else { return }
        self.layout = layout
        notifyPlacementChanged()
    }

    func updateRun(id: String, summary: ActivityRunSummary, items: [ActivityItemSnapshot]) {
        if let model = runModels[id] {
            let previousState = model.summary.state
            model.update(summary: summary, items: items)
            if previousState != summary.state {
                notifyRunStateChanged(model, from: previousState)
            }
        } else {
            let model = ActivityRunModel(id: id, summary: summary, items: items)
            runModels[id] = model
            notifyRunStateChanged(model, from: .idle)
        }
    }

    private func notifyPlacementChanged() {
        observers.values.forEach { $0.placementChanged() }
    }

    private func notifyRunStateChanged(_ model: ActivityRunModel, from previous: ActivityRunState) {
        observers.values.forEach { $0.runStateChanged(model, previous) }
    }
}
