import Foundation
import UIKit
import Services
import AnytypeCore

struct ChatActivityRunSheetData: Identifiable, Equatable {
    let runId: String

    var id: String {
        runId
    }
}

/// Runs placed in a chat timeline. A closed run sits in the gap before the message that closed it;
/// the open run sits at the end of the chat, whatever the newest message is (it may be deleted).
struct ChatActivityTimelineRuns: Equatable, Sendable {
    var beforeMessage: [String: [String]] = [:]
    var afterMessage: [String: [String]] = [:]
    /// Shown after the last message, only while the loaded window reaches the chat's newest message.
    var atTail: [String] = []

    var isEmpty: Bool {
        beforeMessage.isEmpty && afterMessage.isEmpty && atTail.isEmpty
    }

    static func make(layout: ChatActivityLayout, isShown: (ActivityRunLayout) -> Bool) -> ChatActivityTimelineRuns {
        var result = ChatActivityTimelineRuns()
        for run in layout.runs where isShown(run) {
            if let closedBy = run.closedByMessageId, !layout.deletedMessageIds.contains(closedBy) {
                result.beforeMessage[closedBy, default: []].append(run.id)
            } else if run.isOpen {
                guard layout.tailKnown else { continue }
                result.atTail.append(run.id)
            } else if let anchor = run.anchorMessageId {
                // Closed across a gap, or its closing message was deleted: stays where it started
                result.afterMessage[anchor, default: []].append(run.id)
            }
        }
        return result
    }
}

/// The newest chat message as last seen by the screen; `.known(nil)` is an empty chat.
private enum ChatActivityObservedTail {
    case unknown
    case known(ActivityObservedMessage?)
}

/// Live typing and agent activity for one chat or discussion screen. Owned by the screen's view model.
@MainActor
@Observable
final class ChatActivityController {

    let spaceId: String
    let mode: ChatActivityMode

    private(set) var state: ChatActivityState?
    private(set) var participantsByIdentity: [String: Participant] = [:]
    // Discussions: where activity renders, recomputed by the screen with its loaded messages.
    // Split so a comment only observes the runs attached to comments, not typing in threads.
    private(set) var attachedRuns: [String: [String]] = [:]
    private(set) var threadBuckets: [String: DiscussionActivityBucket] = [:]
    private(set) var rootBucket = DiscussionActivityBucket()
    var runSheet: ChatActivityRunSheetData?

    @ObservationIgnored
    private(set) var chatId: String?
    @ObservationIgnored
    let typing: ChatTypingPublisher
    /// Placement inputs changed; the screen rebuilds its list when the result differs.
    @ObservationIgnored
    var onPlacementChange: (@MainActor () -> Void)?

    @ObservationIgnored
    private let store: any ChatActivityStoreProtocol
    /// Terminal states already announced, per run: VoiceOver hears each once.
    @ObservationIgnored
    private var announcedStates: [String: Set<ActivityRunState>] = [:]
    /// The latest message snapshot of the current visit, replayed on attach. Forgotten when the
    /// screen leaves, so a return reconciles only with a snapshot taken after it.
    @ObservationIgnored
    private var tail = ChatActivityObservedTail.unknown
    @ObservationIgnored
    private var tailWaiters: [UUID: CheckedContinuation<Void, Never>] = [:]
    /// SwiftUI may start a new `.task` before the cancelled one has cleaned up.
    @ObservationIgnored
    private var activeRuns = 0

    init(spaceId: String, chatId: String?, mode: ChatActivityMode) {
        let store = Container.shared.chatActivityStore()
        self.spaceId = spaceId
        self.chatId = chatId
        self.mode = mode
        self.store = store
        self.typing = ChatTypingPublisher(spaceId: spaceId, objectId: chatId, store: store)
    }

    /// Collects activity while the calling task lives; the screen runs it from `.task`.
    func run() async {
        guard let chatId else { return }
        if mode == .chat {
            // The message baseline comes first, so the first snapshot can't swallow a live message
            await waitForTail()
            guard !Task.isCancelled else { return }
        }
        guard let state = store.attach(spaceId: spaceId, chatId: chatId, mode: mode) else { return }
        self.state = state
        activeRuns += 1
        let observerId = state.addObserver(ChatActivityStateObserver(
            placementChanged: { [weak self] in
                self?.onPlacementChange?()
            },
            runStateChanged: { [weak self] run, previous in
                self?.announce(run: run, previous: previous)
            }
        ))
        if case .known(let message) = tail {
            store.observeTail(message, in: state)
        }
        typing.setAttached(true)
        onPlacementChange?()

        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(3600))
        }

        state.removeObserver(observerId)
        activeRuns -= 1
        if activeRuns == 0 {
            typing.stop()
            typing.setAttached(false)
            tail = .unknown
        }
        store.detach(state)
    }

    func setChatId(_ chatId: String?) {
        self.chatId = chatId
        typing.setObjectId(chatId)
    }

    /// Activity from unknown participants is skipped; the screen rebuilds its list after this.
    func updateParticipants(_ participants: [Participant]) {
        let byIdentity = Dictionary(participants.map { ($0.identity, $0) }, uniquingKeysWith: { _, last in last })
        guard byIdentity != participantsByIdentity else { return }
        participantsByIdentity = byIdentity
    }

    /// Chats: the newest message from the message store.
    func observeTail(_ message: ChatMessage?) {
        let observed = message.map { ActivityObservedMessage(id: $0.id, orderId: $0.orderID, creator: $0.creator) }
        tail = .known(observed)
        let waiters = tailWaiters.values
        tailWaiters.removeAll()
        waiters.forEach { $0.resume() }
        guard let state, activeRuns > 0 else { return }
        store.observeTail(observed, in: state)
    }

    func onTapRun(id: String) {
        runSheet = ChatActivityRunSheetData(runId: id)
    }

    func runModel(id: String) -> ActivityRunModel? {
        state?.runModel(id: id)
    }

    func participant(identity: String) -> Participant? {
        participantsByIdentity[identity]
    }

    // MARK: - Placement

    func chatTimelineRuns() -> ChatActivityTimelineRuns {
        guard let state else { return ChatActivityTimelineRuns() }
        return ChatActivityTimelineRuns.make(layout: state.layout) { publishersKnown($0.publishers) }
    }

    func makeDiscussionPlacement(
        isLoaded: (String) -> Bool,
        threadRoot: (String) -> String?
    ) -> DiscussionActivityPlacement {
        guard let state else { return DiscussionActivityPlacement() }
        return DiscussionActivityPlacement.make(
            runs: state.layout.runs.filter { publishersKnown($0.publishers) },
            statuses: state.statuses.filter { participantsByIdentity[$0.publisher] != nil },
            typers: state.typers.filter { participantsByIdentity[$0.identity] != nil },
            deletedMessageIds: state.layout.deletedMessageIds,
            isLoaded: isLoaded,
            threadRoot: threadRoot
        )
    }

    func setDiscussionPlacement(_ placement: DiscussionActivityPlacement) {
        if attachedRuns != placement.attached {
            attachedRuns = placement.attached
        }
        if threadBuckets != placement.threads {
            threadBuckets = placement.threads
        }
        if rootBucket != placement.root {
            rootBucket = placement.root
        }
    }

    // MARK: - Rows near the composer

    /// Chats: everyone typing and every text-only status. Discussions: the discussion-level bucket.
    var composerRows: [ChatActivityRowData] {
        guard let state else { return [] }
        switch mode {
        case .chat:
            return makeRows(
                statuses: state.statuses.map(\.publisher),
                typingIdentities: state.typers.map(\.identity)
            )
        case .discussion:
            return makeRows(bucket: rootBucket)
        }
    }

    func makeRows(bucket: DiscussionActivityBucket) -> [ChatActivityRowData] {
        makeRows(statuses: bucket.statusPublishers, typingIdentities: bucket.typingIdentities)
    }

    func runRow(runId: String) -> ChatActivityRowData? {
        guard let run = state?.runModel(id: runId) else { return nil }
        let participants = run.summary.publishers.compactMap { participantsByIdentity[$0] }
        guard participants.isNotEmpty else { return nil }
        return ChatActivityRowData(
            id: runId,
            icons: participants.map(\.activityIcon),
            text: ChatActivityText.runLine(names: participants.map(\.title), summary: run.summary),
            accessibilityLabel: ChatActivityText.runAccessibilityLabel(names: participants.map(\.title), summary: run.summary),
            trailing: ChatActivityRowTrailing(state: run.summary.state)
        )
    }

    // MARK: - Private

    private func waitForTail() async {
        guard case .unknown = tail else { return }
        let id = UUID()
        await withTaskCancellationHandler {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                if Task.isCancelled {
                    continuation.resume()
                } else {
                    tailWaiters[id] = continuation
                }
            }
        } onCancel: { [weak self] in
            Task { @MainActor in
                self?.tailWaiters.removeValue(forKey: id)?.resume()
            }
        }
    }

    private func makeRows(statuses: [String], typingIdentities: [String]) -> [ChatActivityRowData] {
        guard let state else { return [] }
        var rows: [ChatActivityRowData] = []
        for publisher in statuses {
            guard let participant = participantsByIdentity[publisher],
                  let status = state.statuses.first(where: { $0.publisher == publisher }) else { continue }
            let text = ChatActivityText.statusLine(name: participant.title, text: status.text)
            rows.append(ChatActivityRowData(
                id: "status-\(publisher)",
                icons: [participant.activityIcon],
                text: text,
                accessibilityLabel: text,
                trailing: .dots
            ))
        }
        // Unknown participants are skipped until they sync
        let typers = typingIdentities.compactMap { participantsByIdentity[$0] }
        if typers.isNotEmpty {
            let text = ChatActivityText.typing(names: typers.map(\.title))
            rows.append(ChatActivityRowData(
                id: "typing",
                icons: typers.map(\.activityIcon),
                text: text,
                accessibilityLabel: text,
                trailing: .dots
            ))
        }
        return rows
    }

    private func publishersKnown(_ publishers: [String]) -> Bool {
        publishers.allSatisfy { participantsByIdentity[$0] != nil }
    }

    /// Finished and failed are each announced once per run, never on heartbeats.
    private func announce(run: ActivityRunModel, previous: ActivityRunState) {
        let state = run.summary.state
        guard UIAccessibility.isVoiceOverRunning,
              !announcedStates[run.id, default: []].contains(state) else { return }
        let names = run.summary.publishers.compactMap { participantsByIdentity[$0]?.title }
        guard let text = ChatActivityText.announcement(names: names, state: state, previous: previous) else { return }
        announcedStates[run.id, default: []].insert(state)
        UIAccessibility.post(notification: .announcement, argument: text)
    }
}

private extension Participant {
    var activityIcon: Icon {
        icon.map { .object($0) } ?? Icon.object(.profile(.placeholder))
    }
}
