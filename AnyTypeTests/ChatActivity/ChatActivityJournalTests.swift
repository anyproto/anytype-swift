import Foundation
import Testing
@testable import Anytype

private let start = Date(timeIntervalSinceReferenceDate: 1_000)

private func at(_ seconds: TimeInterval) -> Date {
    start.addingTimeInterval(seconds)
}

private func status(_ json: String) -> ChatStatusPayload {
    guard let payload = ChatStatusPayload.decode(Data(json.utf8)) else {
        Issue.record("Malformed test payload: \(json)")
        return ChatStatusPayload(text: nil)
    }
    return payload
}

private func toolEvent(_ callId: String, status lifecycle: String? = nil, text: String? = nil, extra: String = "") -> ChatStatusPayload {
    var fields = [#""tool_call_id":"\#(callId)""#, #""tool_name":"search""#]
    if let lifecycle {
        fields.append(#""status":"\#(lifecycle)""#)
    }
    if !extra.isEmpty {
        fields.append(extra)
    }
    let textPart = text.map { #""text":"\#($0)","# } ?? ""
    return status("{\(textPart)\"data\":{\(fields.joined(separator: ","))}}")
}

private func message(_ id: String, order: String, creator: String = "someone") -> ActivityObservedMessage {
    ActivityObservedMessage(id: id, orderId: order, creator: creator)
}

@Suite
struct ChatActivityJournalTests {

    private let agent = "agent"

    private func makeChatJournal(tail: ActivityObservedMessage? = message("m0", order: "000")) -> ChatActivityJournal {
        var journal = ChatActivityJournal(mode: .chat)
        _ = journal.observeTail(tail)
        return journal
    }

    // Acceptance: start, progress and complete for one tool_call_id give one item and a count of 1
    @Test func oneItemPerToolCall() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("call_1", status: "in_progress", extra: #""query":"q""#), publisher: agent, now: at(0))
        _ = journal.applyStatus(toolEvent("call_1", status: "in_progress", text: "Halfway"), publisher: agent, now: at(2))
        _ = journal.applyStatus(toolEvent("call_1", status: "complete", text: "Found 3", extra: #""result":{"matches":3}"#), publisher: agent, now: at(4))

        #expect(journal.runs.count == 1)
        let run = try #require(journal.runs.first)
        let summary = try #require(journal.summary(runId: run.id, now: at(4)))
        #expect(summary.toolCallCount == 1)
        #expect(summary.state == .completed)
        #expect(summary.latestText == "Found 3")
        let item = try #require(journal.items(inRun: run.id).first)
        #expect(item.data["query"]?.stringValue == "q")
        #expect(item.data["result"] == ActivityJSON.parse(#"{"matches":3}"#))
    }

    @Test func sameIdFromAnotherSenderIsAnotherCall() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("call_1", status: "in_progress"), publisher: "agent-a", now: at(0))
        _ = journal.applyStatus(toolEvent("call_1", status: "in_progress"), publisher: "agent-b", now: at(0))
        let run = try #require(journal.runs.first)
        #expect(journal.summary(runId: run.id, now: at(0))?.toolCallCount == 2)
        #expect(run.publishers == ["agent-a", "agent-b"])
    }

    // Acceptance: a chat message between A's start and finish keeps A in its first run; B after the message opens a new run
    @Test func messageClosesTheRunButNotTheCall() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        _ = journal.applyStatus(toolEvent("B", status: "in_progress"), publisher: agent, now: at(0.5))
        let boundary = journal.observeMessage(message("m1", order: "001"))
        #expect(boundary.layoutChanged)
        _ = journal.applyStatus(toolEvent("A", status: "complete"), publisher: agent, now: at(1))
        _ = journal.applyStatus(toolEvent("C", status: "in_progress"), publisher: agent, now: at(1.5))

        #expect(journal.runs.count == 2)
        let first = journal.runs[0]
        let second = journal.runs[1]
        #expect(!first.isOpen)
        #expect(first.closedByMessageId == "m1")
        #expect(first.anchor?.id == "m0")
        #expect(journal.items(inRun: first.id).map(\.toolCallId) == ["A", "B"])
        #expect(journal.items(inRun: first.id).first?.lifecycle == .complete)
        #expect(journal.items(inRun: second.id).map(\.toolCallId) == ["C"])
        #expect(second.anchor?.id == "m1")
        // A message never completes or fails a call
        #expect(journal.items(inRun: first.id).last?.lifecycle == .inProgress)
    }

    @Test func historyAtOrBeforeTheTailIsNotABoundary() {
        var journal = makeChatJournal(tail: message("m5", order: "005"))
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        let update = journal.observeMessage(message("m3", order: "003"))
        #expect(!update.layoutChanged)
        #expect(journal.runs.first?.isOpen == true)
    }

    @Test func repeatedMessageIdsAreDeduplicated() {
        var journal = makeChatJournal()
        _ = journal.observeMessage(message("m1", order: "001"))
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        _ = journal.observeMessage(message("m1", order: "001"))
        #expect(journal.runs.first?.isOpen == true)
    }

    // Acceptance: a late in_progress after complete does not turn the call back to running
    @Test func lifecycleOnlyMovesForward() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        _ = journal.applyStatus(toolEvent("A", status: "complete"), publisher: agent, now: at(1))
        _ = journal.applyStatus(toolEvent("A", status: "in_progress", text: "stale", extra: #""query":"late""#), publisher: agent, now: at(2))
        let item = try #require(journal.items.values.first)
        #expect(item.lifecycle == .complete)
        // The conflicting event is dropped whole
        #expect(item.data["query"] == nil)
        #expect(item.text == nil)
    }

    @Test func terminalUpdateWithoutStatusStillAddsAResult() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "error"), publisher: agent, now: at(0))
        _ = journal.applyStatus(toolEvent("A", extra: #""result":"timeout""#), publisher: agent, now: at(1))
        let item = try #require(journal.items.values.first)
        #expect(item.lifecycle == .error)
        #expect(item.data["result"]?.stringValue == "timeout")
    }

    @Test func newIdFirstSeenAsTerminalCreatesAnItem() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "error"), publisher: agent, now: at(0))
        let run = try #require(journal.runs.first)
        let summary = try #require(journal.summary(runId: run.id, now: at(0)))
        #expect(summary.failedCount == 1)
        #expect(summary.state == .failed)
    }

    @Test func unknownOrMissingStatusShowsNoBadge() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A"), publisher: agent, now: at(0))
        _ = journal.applyStatus(toolEvent("B", status: "queued"), publisher: agent, now: at(0))
        #expect(journal.items.values.allSatisfy { $0.lifecycle == nil })
    }

    // Acceptance: a running call that goes silent shows "No recent updates" after 10 s, never "Failed"
    @Test func silentRunningCallGoesStaleNotFailed() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        let runId = try #require(journal.runs.first?.id)
        #expect(journal.summary(runId: runId, now: at(9.9))?.state == .running)
        let stale = try #require(journal.summary(runId: runId, now: at(10)))
        #expect(stale.state == .stale)
        #expect(stale.failedCount == 0)
        #expect(stale.runningCount == 1)
        // A fresh update brings it back
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(11))
        #expect(journal.summary(runId: runId, now: at(11))?.state == .running)
    }

    // Acceptance: a failed call shows on the compact line without opening the sheet
    @Test func failureWinsTheRunState() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "complete"), publisher: agent, now: at(0))
        _ = journal.applyStatus(toolEvent("B", status: "error"), publisher: agent, now: at(0))
        _ = journal.applyStatus(toolEvent("C", status: "in_progress"), publisher: agent, now: at(0))
        let runId = try #require(journal.runs.first?.id)
        let summary = try #require(journal.summary(runId: runId, now: at(0)))
        #expect(summary.state == .failed)
        #expect(summary.toolCallCount == 3)
        #expect(summary.runningCount == 1)
        #expect(summary.failedCount == 1)
    }

    @Test func textOnlyStatusIsTransient() {
        var journal = makeChatJournal()
        let update = journal.applyStatus(status(#"{"text":"Searching docs"}"#), publisher: agent, now: at(0))
        #expect(update.transientChanged)
        #expect(journal.runs.isEmpty)
        #expect(journal.transient.first?.text == "Searching docs")
        let sweptEarly = journal.sweep(now: at(9.9))
        #expect(!sweptEarly)
        let sweptAtExpiry = journal.sweep(now: at(10))
        #expect(sweptAtExpiry)
        #expect(journal.transient.isEmpty)
    }

    @Test func messageFromTheSenderClearsItsTransientStatus() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(status(#"{"text":"Searching docs"}"#), publisher: agent, now: at(0))
        _ = journal.observeMessage(message("m1", order: "001", creator: "someone-else"))
        #expect(journal.transient.count == 1)
        _ = journal.observeMessage(message("m2", order: "002", creator: agent))
        #expect(journal.transient.isEmpty)
    }

    @Test func textOnlyEventsNeverSplitARun() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        _ = journal.applyStatus(status(#"{"text":"Thinking"}"#), publisher: agent, now: at(1))
        _ = journal.applyStatus(toolEvent("B", status: "in_progress"), publisher: agent, now: at(30))
        #expect(journal.runs.count == 1)
    }

    @Test func equalGenericSnapshotsCountOnce() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(status(#"{"text":"Working","data":{"step":1,"of":3}}"#), publisher: agent, now: at(0))
        _ = journal.applyStatus(status(#"{"text":"Working","data":{"of":3,"step":1}}"#), publisher: agent, now: at(2))
        #expect(journal.items.count == 1)
        _ = journal.applyStatus(status(#"{"text":"Working","data":{"step":2,"of":3}}"#), publisher: agent, now: at(4))
        #expect(journal.items.count == 2)
        let runId = try #require(journal.runs.first?.id)
        let summary = try #require(journal.summary(runId: runId, now: at(4)))
        #expect(!summary.isToolCallsOnly)
        #expect(summary.itemCount == 2)
    }

    @Test func textOnlyBetweenEqualSnapshotsStartsANewEntry() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(status(#"{"data":{"step":1}}"#), publisher: agent, now: at(0))
        _ = journal.applyStatus(status(#"{"text":"Thinking"}"#), publisher: agent, now: at(1))
        _ = journal.applyStatus(status(#"{"data":{"step":1}}"#), publisher: agent, now: at(2))
        #expect(journal.items.count == 2)
    }

    @Test func knownCallUpdatesStayInTheirClosedRun() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        _ = journal.observeMessage(message("m1", order: "001"))
        let update = journal.applyStatus(toolEvent("A", status: "complete"), publisher: agent, now: at(1))
        let firstRunId = journal.runs[0].id
        #expect(update.runIds == [firstRunId])
        #expect(!update.layoutChanged)
        #expect(journal.runs.count == 1)
    }

    @Test func reattachingAfterTheTailMovedClosesTheOpenRunWithoutAMessage() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        journal.markDetached()
        let update = journal.observeTail(message("m9", order: "009"))
        #expect(update.layoutChanged)
        #expect(journal.runs[0].isOpen == false)
        #expect(journal.runs[0].closedByMessageId == nil)
        #expect(journal.runs[0].anchor?.id == "m0")
        _ = journal.applyStatus(toolEvent("B", status: "in_progress"), publisher: agent, now: at(1))
        #expect(journal.runs[1].anchor?.id == "m9")
    }

    @Test func reattachingWithTheSameTailKeepsTheRunOpen() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        journal.markDetached()
        _ = journal.observeTail(message("m0", order: "000"))
        #expect(journal.runs[0].isOpen)
    }

    @Test func freshActivityIsTrackedPerSender() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(status(#"{"text":"Searching"}"#), publisher: agent, now: at(0))
        #expect(journal.hasFreshActivity(publisher: agent, now: at(9)))
        #expect(!journal.hasFreshActivity(publisher: agent, now: at(10)))
        #expect(!journal.hasFreshActivity(publisher: "someone", now: at(0)))
    }
}

extension ChatActivityJournalTests {

    @Test func firstTailMakesEarlyRunsPlaceable() {
        var journal = ChatActivityJournal(mode: .chat)
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        #expect(!journal.tailKnown)
        let update = journal.observeTail(message("m0", order: "000"))
        #expect(update.layoutChanged)
        #expect(journal.tailKnown)
    }

    @Test func laterSnapshotsNeverCloseRuns() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        // Only live messages, in event order, close runs: m1 arrives as an event later
        let update = journal.observeTail(message("m2", order: "002"))
        #expect(update.isEmpty)
        #expect(journal.runs[0].isOpen)
        _ = journal.observeMessage(message("m1", order: "001"))
        #expect(journal.runs[0].closedByMessageId == "m1")
    }

    @Test func newCallAfterReturningStartsAFreshRun() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        journal.markDetached()
        _ = journal.applyStatus(toolEvent("B", status: "in_progress"), publisher: agent, now: at(1))
        #expect(journal.runs.count == 2)
        #expect(journal.runs[0].isOpen == false)
        #expect(journal.runs[0].closedByMessageId == nil)
        #expect(journal.runs[1].isOpen)
        // The reconciling snapshot no longer touches the new run
        _ = journal.observeTail(message("m9", order: "009"))
        #expect(journal.runs[1].isOpen)
        #expect(journal.tail?.id == "m9")
    }

    @Test func liveMessageAfterReturningClosesTheGapRunWithoutIt() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        journal.markDetached()
        let update = journal.observeMessage(message("m5", order: "005"))
        #expect(update.layoutChanged)
        #expect(journal.runs[0].closedByMessageId == nil)
        #expect(!journal.runs[0].isOpen)
        #expect(journal.tail?.id == "m5")
    }

    @Test func duplicateMessageIsNotNew() {
        var journal = makeChatJournal()
        #expect(journal.observeMessage(message("m1", order: "001")).isNewMessage)
        #expect(!journal.observeMessage(message("m1", order: "001")).isNewMessage)
    }

    @Test func secondPublisherJoiningARunIsALayoutChange() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: "agent-a", now: at(0))
        let joined = journal.applyStatus(toolEvent("B", status: "in_progress"), publisher: "agent-b", now: at(0))
        #expect(joined.layoutChanged)
        let heartbeat = journal.applyStatus(toolEvent("B", status: "in_progress"), publisher: "agent-b", now: at(2))
        #expect(!heartbeat.layoutChanged)
    }

    @Test func terminalOutcomeCannotFlip() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "complete"), publisher: agent, now: at(0))
        _ = journal.applyStatus(toolEvent("A", status: "error"), publisher: agent, now: at(1))
        #expect(try #require(journal.items.values.first).lifecycle == .complete)
    }

    @Test func unknownStatusLaterBecomesKnown() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A"), publisher: agent, now: at(0))
        #expect(try #require(journal.items.values.first).lifecycle == nil)
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(1))
        #expect(try #require(journal.items.values.first).lifecycle == .inProgress)
        _ = journal.applyStatus(toolEvent("A", status: "complete"), publisher: agent, now: at(2))
        #expect(try #require(journal.items.values.first).lifecycle == .complete)
    }

    @Test func messageFromTheSenderEndsItsFreshActivity() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(status(#"{"text":"Searching"}"#), publisher: agent, now: at(0))
        _ = journal.observeMessage(message("m1", order: "001", creator: agent))
        #expect(!journal.hasFreshActivity(publisher: agent, now: at(1)))
    }
}

extension ChatActivityJournalTests {

    @Test func leavingDropsTransientStatuses() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(status(#"{"text":"Searching"}"#), publisher: agent, now: at(0))
        journal.markDetached()
        #expect(journal.transient.isEmpty)
    }

    @Test func aRejectedUpdateIsNotFreshActivity() {
        var journal = makeChatJournal()
        _ = journal.applyStatus(toolEvent("A", status: "complete"), publisher: agent, now: at(0))
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(15))
        #expect(!journal.hasFreshActivity(publisher: agent, now: at(15)))
    }

    @Test func repeatedGenericSnapshotBecomesTheLatestTextAgain() throws {
        var journal = makeChatJournal()
        _ = journal.applyStatus(status(#"{"text":"Reading","data":{"step":1}}"#), publisher: agent, now: at(0))
        _ = journal.applyStatus(toolEvent("A", status: "in_progress", text: "Searching"), publisher: agent, now: at(1))
        _ = journal.applyStatus(status(#"{"text":"Reading","data":{"step":1}}"#), publisher: agent, now: at(2))
        let runId = try #require(journal.runs.first?.id)
        let summary = try #require(journal.summary(runId: runId, now: at(2)))
        #expect(summary.latestText == "Reading")
        #expect(summary.itemCount == 2)
    }
}

@Suite
struct DiscussionActivityJournalTests {

    private let agent = "agent"

    // Acceptance: someone else commenting while the agent works does not split its run
    @Test func otherAuthorsDoNotCloseTheRun() {
        var journal = ChatActivityJournal(mode: .discussion)
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        _ = journal.observeMessage(message("c1", order: "001", creator: "anna"))
        _ = journal.applyStatus(toolEvent("B", status: "in_progress"), publisher: agent, now: at(1))
        #expect(journal.runs.count == 1)
        #expect(journal.runs[0].isOpen)
    }

    // Acceptance: then the agent's comment with the finished run under its header
    @Test func theSendersOwnCommentClosesAndOwnsTheRun() {
        var journal = ChatActivityJournal(mode: .discussion)
        _ = journal.applyStatus(toolEvent("A", status: "complete"), publisher: agent, now: at(0))
        let update = journal.observeMessage(message("c1", order: "001", creator: agent))
        #expect(update.layoutChanged)
        #expect(journal.runs[0].closedByMessageId == "c1")
        #expect(!journal.runs[0].isOpen)
    }

    @Test func eachSenderHasItsOwnRun() {
        var journal = ChatActivityJournal(mode: .discussion)
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: "agent-a", now: at(0))
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: "agent-b", now: at(0))
        _ = journal.observeMessage(message("c1", order: "001", creator: "agent-a"))
        #expect(journal.runs.count == 2)
        #expect(journal.runs[0].closedByMessageId == "c1")
        #expect(journal.runs[1].isOpen)
    }

    @Test func aDifferentReplyToClosesTheRunWithoutAComment() {
        var journal = ChatActivityJournal(mode: .discussion)
        _ = journal.applyStatus(status(#"{"reply_to":"post-1","data":{"tool_call_id":"A"}}"#), publisher: agent, now: at(0))
        _ = journal.applyStatus(status(#"{"reply_to":"post-2","data":{"tool_call_id":"B"}}"#), publisher: agent, now: at(1))
        #expect(journal.runs.count == 2)
        #expect(journal.runs[0].isOpen == false)
        #expect(journal.runs[0].closedByMessageId == nil)
        #expect(journal.runs[0].replyTo == "post-1")
        #expect(journal.runs[1].replyTo == "post-2")
    }

    @Test func knownCallUpdatesAndTextOnlyNeverCloseARun() {
        var journal = ChatActivityJournal(mode: .discussion)
        _ = journal.applyStatus(status(#"{"reply_to":"post-1","data":{"tool_call_id":"A"}}"#), publisher: agent, now: at(0))
        _ = journal.applyStatus(status(#"{"reply_to":"post-2","text":"Thinking"}"#), publisher: agent, now: at(1))
        _ = journal.applyStatus(status(#"{"reply_to":"post-2","data":{"tool_call_id":"A","status":"complete"}}"#), publisher: agent, now: at(2))
        #expect(journal.runs.count == 1)
        #expect(journal.runs[0].isOpen)
    }

    @Test func anOlderCommentFromTheSenderDoesNotCloseALaterRun() {
        var journal = ChatActivityJournal(mode: .discussion)
        _ = journal.observeMessage(message("c5", order: "005", creator: "anna"))
        _ = journal.applyStatus(toolEvent("A", status: "in_progress"), publisher: agent, now: at(0))
        _ = journal.observeMessage(message("c3", order: "003", creator: agent))
        #expect(journal.runs[0].isOpen)
    }
}

@Suite
struct DiscussionActivityPlacementTests {

    private func run(
        _ id: String,
        replyTo: String? = nil,
        isOpen: Bool = true,
        closedBy: String? = nil
    ) -> ActivityRunLayout {
        ActivityRunLayout(id: id, publishers: ["agent"], replyTo: replyTo, anchorMessageId: nil, isOpen: isOpen, closedByMessageId: closedBy)
    }

    /// root1 ← r1 ← r2 (a reply to a reply), root2. "late" is not loaded.
    private let roots: [String: String] = ["root1": "root1", "r1": "root1", "r2": "root1", "root2": "root2"]

    private func place(
        runs: [ActivityRunLayout] = [],
        statuses: [ActivityStatusLine] = [],
        typers: [ChatTypingEntry] = [],
        deleted: Set<String> = [],
        roots: [String: String]? = nil
    ) -> DiscussionActivityPlacement {
        let roots = roots ?? self.roots
        return DiscussionActivityPlacement.make(
            runs: runs,
            statuses: statuses,
            typers: typers,
            deletedMessageIds: deleted,
            isLoaded: { roots[$0] != nil },
            threadRoot: { roots[$0] }
        )
    }

    // Acceptance: discussion without reply_to — a running line at the discussion level, then the finished run under the comment
    @Test func runWithoutReplyToGoesToTheRootThenUnderItsComment() {
        #expect(place(runs: [run("run-1")]).root.runIds == ["run-1"])
        let finished = place(runs: [run("run-1", isOpen: false, closedBy: "root2")])
        #expect(finished.attached == ["root2": ["run-1"]])
        #expect(finished.root.isEmpty)
    }

    // Acceptance: reply_to naming a reply deep in a thread puts the line at that thread's end
    @Test func replyToADeepReplyResolvesToTheThread() {
        let placement = place(runs: [run("run-1", replyTo: "r2")])
        #expect(placement.threads["root1"]?.runIds == ["run-1"])
        #expect(placement.root.isEmpty)
    }

    // Acceptance: an unloaded id starts at the discussion level and moves in when the message loads
    @Test func unloadedReplyToFallsBackAndMovesInOnLoad() {
        let runs = [run("run-1", replyTo: "late")]
        #expect(place(runs: runs).root.runIds == ["run-1"])
        var loaded = roots
        loaded["late"] = "root2"
        #expect(place(runs: runs, roots: loaded).threads["root2"]?.runIds == ["run-1"])
    }

    @Test func runClosedByADeletedOrPagedOutCommentIsHidden() {
        let deleted = place(runs: [run("run-1", isOpen: false, closedBy: "root2")], deleted: ["root2"])
        #expect(deleted.attached.isEmpty)
        #expect(deleted.root.isEmpty)
        let pagedOut = place(runs: [run("run-1", isOpen: false, closedBy: "gone")])
        #expect(pagedOut.attached.isEmpty)
        #expect(pagedOut.root.isEmpty)
    }

    @Test func runClosedByAReplyToChangeStaysInItsThread() {
        let placement = place(runs: [run("run-1", replyTo: "r1", isOpen: false)])
        #expect(placement.threads["root1"]?.runIds == ["run-1"])
    }

    // Acceptance: reply-composer typing shows at that thread's end; main composer typing at the discussion level
    @Test func typingFollowsReplyTo() {
        let placement = place(typers: [
            ChatTypingEntry(identity: "anna", replyTo: "root1"),
            ChatTypingEntry(identity: "ben", replyTo: nil)
        ])
        #expect(placement.threads["root1"]?.typingIdentities == ["anna"])
        #expect(placement.root.typingIdentities == ["ben"])
        #expect(placement.threadRootIds == ["root1"])
    }

    @Test func textOnlyStatusFollowsReplyTo() {
        let placement = place(statuses: [ActivityStatusLine(publisher: "agent", text: "Reading", replyTo: "r1")])
        #expect(placement.threads["root1"]?.statusPublishers == ["agent"])
    }
}

@Suite
struct ChatActivityTimelineRunsTests {

    private func run(_ id: String, isOpen: Bool, closedBy: String? = nil, anchor: String? = nil, publisher: String = "agent") -> ActivityRunLayout {
        ActivityRunLayout(id: id, publishers: [publisher], replyTo: nil, anchorMessageId: anchor, isOpen: isOpen, closedByMessageId: closedBy)
    }

    @Test func closedRunsPrecedeTheirMessageAndTheOpenRunFollowsTheTail() {
        let layout = ChatActivityLayout(
            runs: [
                run("run-1", isOpen: false, closedBy: "m1", anchor: "m0"),
                run("run-2", isOpen: true, anchor: "m1"),
                run("run-0", isOpen: false, anchor: "m-gap")
            ],
            tailKnown: true,
            tailMessageId: "m1"
        )
        let placement = ChatActivityTimelineRuns.make(layout: layout) { _ in true }
        #expect(placement.beforeMessage == ["m1": ["run-1"]])
        #expect(placement.afterMessage == ["m-gap": ["run-0"]])
        #expect(placement.atTail == ["run-2"])
    }

    @Test func openRunWaitsForTheTailThenFollowsTheNewestMessage() {
        let unknown = ChatActivityLayout(runs: [run("run-1", isOpen: true)], tailKnown: false)
        #expect(ChatActivityTimelineRuns.make(layout: unknown) { _ in true }.isEmpty)
        // Also when the newest message was deleted or the chat is empty
        let empty = ChatActivityLayout(runs: [run("run-1", isOpen: true)], tailKnown: true, tailMessageId: nil)
        #expect(ChatActivityTimelineRuns.make(layout: empty) { _ in true }.atTail == ["run-1"])
    }

    @Test func runsFromUnknownParticipantsAreSkipped() {
        let layout = ChatActivityLayout(runs: [run("run-1", isOpen: true, publisher: "stranger")], tailKnown: true, tailMessageId: "m1")
        let placement = ChatActivityTimelineRuns.make(layout: layout) { !$0.publishers.contains("stranger") }
        #expect(placement.isEmpty)
    }

    @Test func runClosedByADeletedMessageStaysWhereItStarted() {
        let layout = ChatActivityLayout(
            runs: [run("run-1", isOpen: false, closedBy: "m1", anchor: "m0")],
            tailKnown: true,
            tailMessageId: "m2",
            deletedMessageIds: ["m1"]
        )
        let placement = ChatActivityTimelineRuns.make(layout: layout) { _ in true }
        #expect(placement.beforeMessage.isEmpty)
        #expect(placement.afterMessage == ["m0": ["run-1"]])
    }
}
