import Foundation
import Testing
@testable import Anytype

@Suite
struct ChatActivityTextTests {

    private func summary(
        toolCalls: Int,
        items: Int? = nil,
        running: Int = 0,
        failed: Int = 0,
        text: String? = nil,
        state: ActivityRunState = .running
    ) -> ActivityRunSummary {
        ActivityRunSummary(
            publishers: ["agent"],
            toolCallCount: toolCalls,
            itemCount: items ?? toolCalls,
            runningCount: running,
            failedCount: failed,
            latestText: text,
            state: state
        )
    }

    @Test func typingLabels() {
        #expect(ChatActivityText.typing(names: ["Anna"]) == "Anna is typing")
        #expect(ChatActivityText.typing(names: ["Anna", "Ben"]) == "Anna and Ben are typing")
        #expect(ChatActivityText.typing(names: ["Anna", "Ben", "Cy", "Di"]) == "Anna and 3 others are typing")
    }

    @Test func runLine() {
        let line = ChatActivityText.runLine(
            names: ["Agent"],
            summary: summary(toolCalls: 3, running: 1, failed: 1, text: "Reading the timetable")
        )
        #expect(line == "Agent · 3 tool calls · 1 running · 1 failed · Reading the timetable")
    }

    @Test func runLineCountsActivitiesWhenMixed() {
        let line = ChatActivityText.runLine(names: ["Agent"], summary: summary(toolCalls: 3, items: 4))
        #expect(line == "Agent · 4 activities")
    }

    @Test func missingTextReadsTyping() {
        #expect(ChatActivityText.statusLine(name: "Agent", text: nil) == "Agent · Typing")
        #expect(ChatActivityText.statusLine(name: "Agent", text: "Searching docs") == "Agent · Searching docs")
    }

    @Test func callStatusLabels() {
        #expect(ChatActivityText.status(lifecycle: .inProgress, isFresh: true) == "Running")
        #expect(ChatActivityText.status(lifecycle: .inProgress, isFresh: false) == "No recent updates")
        #expect(ChatActivityText.status(lifecycle: .complete, isFresh: false) == "Completed")
        #expect(ChatActivityText.status(lifecycle: .error, isFresh: true) == "Failed")
        #expect(ChatActivityText.status(lifecycle: nil, isFresh: true) == nil)
    }

    @Test func announcesFinishAndFailureOnly() {
        #expect(ChatActivityText.announcement(names: ["Agent"], state: .completed, previous: .running) == "Agent finished")
        #expect(ChatActivityText.announcement(names: ["Agent"], state: .failed, previous: .running) == "Agent: a tool call failed")
        #expect(ChatActivityText.announcement(names: ["Agent"], state: .stale, previous: .running) == nil)
    }

    @Test func accessibilityLabelSpeaksTheGlyph() {
        let completed = ChatActivityText.runAccessibilityLabel(names: ["Agent"], summary: summary(toolCalls: 2, state: .completed))
        #expect(completed == "Agent, 2 tool calls, Completed")
        let stale = ChatActivityText.runAccessibilityLabel(names: ["Agent"], summary: summary(toolCalls: 1, running: 1, state: .stale))
        #expect(stale == "Agent, 1 tool call, 1 running, No recent updates")
    }
}
