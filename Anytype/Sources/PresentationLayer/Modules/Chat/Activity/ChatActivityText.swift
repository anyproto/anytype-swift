import Foundation
import Services
import AnytypeCore

enum ChatActivityRowTrailing: Equatable {
    case dots
    case completed
    case failed
    case none

    init(state: ActivityRunState) {
        switch state {
        case .running:
            self = .dots
        case .completed:
            self = .completed
        case .failed:
            self = .failed
        case .stale, .idle:
            self = .none
        }
    }
}

/// One compact row: typing, a text-only agent status, or a run summary.
struct ChatActivityRowData: Identifiable, Equatable {
    let id: String
    let icons: [Icon]
    let text: String
    let accessibilityLabel: String
    let trailing: ChatActivityRowTrailing
}

/// Localized labels. The agent's own `text` and JSON keys are never translated.
enum ChatActivityText {

    private static let separator = " · "

    /// "Anna is typing", "Anna and Ben are typing", "Anna and 3 others are typing".
    static func typing(names: [String]) -> String {
        switch names.count {
        case 0:
            return ""
        case 1:
            return Loc.Chat.Activity.Typing.one(names[0])
        case 2:
            return Loc.Chat.Activity.Typing.several(names[0], names[1])
        default:
            return Loc.Chat.Activity.Typing.several(names[0], Loc.Chat.Activity.Typing.others(names.count - 1))
        }
    }

    /// "Agent · Searching docs"; missing text reads "Typing".
    static func statusLine(name: String, text: String?) -> String {
        name + separator + displayText(text)
    }

    static func displayText(_ text: String?) -> String {
        text ?? Loc.Chat.Activity.defaultText
    }

    /// "Agent · 3 tool calls · 1 running · 1 failed · Reading the timetable".
    static func runLine(names: [String], summary: ActivityRunSummary) -> String {
        var parts = [joined(names: names)] + counts(summary: summary)
        if let text = summary.latestText {
            parts.append(text)
        }
        return parts.joined(separator: separator)
    }

    /// Sheet title: "Agent · 3 tool calls".
    static func runTitle(names: [String], summary: ActivityRunSummary) -> String {
        [joined(names: names), count(summary: summary)].joined(separator: separator)
    }

    /// The glyph's meaning is spoken too: a check or a quiet run is otherwise invisible to VoiceOver.
    static func runAccessibilityLabel(names: [String], summary: ActivityRunSummary) -> String {
        var parts = [joined(names: names)] + counts(summary: summary)
        switch summary.state {
        case .completed:
            parts.append(Loc.Chat.Activity.Status.completed)
        case .stale:
            parts.append(Loc.Chat.Activity.Status.noRecentUpdates)
        case .running, .failed, .idle:
            break
        }
        if let text = summary.latestText {
            parts.append(text)
        }
        return parts.joined(separator: ", ")
    }

    static func toolName(_ name: String?) -> String {
        name ?? Loc.Chat.Activity.toolCall
    }

    /// Status label for one call; nil shows no badge.
    static func status(lifecycle: ActivityLifecycle?, isFresh: Bool) -> String? {
        switch lifecycle {
        case .inProgress:
            isFresh ? Loc.Chat.Activity.Status.running : Loc.Chat.Activity.Status.noRecentUpdates
        case .complete:
            Loc.Chat.Activity.Status.completed
        case .error:
            Loc.Chat.Activity.Status.failed
        case nil:
            nil
        }
    }

    /// Spoken once when a run finishes or fails.
    static func announcement(names: [String], state: ActivityRunState, previous: ActivityRunState) -> String? {
        let name = joined(names: names)
        guard name.isNotEmpty else { return nil }
        switch state {
        case .completed:
            return Loc.Chat.Activity.Announcement.completed(name)
        case .failed:
            return Loc.Chat.Activity.Announcement.failed(name)
        case .running, .stale, .idle:
            return nil
        }
    }

    // MARK: - Private

    private static func joined(names: [String]) -> String {
        ListFormatter.localizedString(byJoining: names)
    }

    private static func count(summary: ActivityRunSummary) -> String {
        summary.isToolCallsOnly
            ? Loc.Chat.Activity.toolCalls(summary.toolCallCount)
            : Loc.Chat.Activity.activities(summary.itemCount)
    }

    private static func counts(summary: ActivityRunSummary) -> [String] {
        var parts = [count(summary: summary)]
        if summary.runningCount > 0 {
            parts.append(Loc.Chat.Activity.running(summary.runningCount))
        }
        if summary.failedCount > 0 {
            parts.append(Loc.Chat.Activity.failed(summary.failedCount))
        }
        return parts
    }
}
