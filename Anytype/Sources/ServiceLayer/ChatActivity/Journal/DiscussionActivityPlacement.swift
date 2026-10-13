import Foundation

struct DiscussionActivityBucket: Equatable, Sendable {
    var runIds: [String] = []
    var statusPublishers: [String] = []
    var typingIdentities: [String] = []

    var isEmpty: Bool {
        runIds.isEmpty && statusPublishers.isEmpty && typingIdentities.isEmpty
    }
}

/// Where discussion activity renders. Pure.
///
/// - A finished run sits under the header of the comment that closed it. It is hidden while that
///   comment is deleted or not loaded (iOS pages discussions; a paged-out comment's run waits).
/// - Everything else (open runs, runs closed by a `reply_to` change, text-only status, typing) goes
///   to the end of the thread its `reply_to` / `replyTo` resolves to, else to the discussion level.
struct DiscussionActivityPlacement: Equatable, Sendable {
    /// Comment id → runs it closed.
    var attached: [String: [String]] = [:]
    /// Top-level post id → activity at the end of its thread.
    var threads: [String: DiscussionActivityBucket] = [:]
    /// Discussion level, above the main composer.
    var root = DiscussionActivityBucket()

    /// - Parameters:
    ///   - isLoaded: whether a message is in the loaded window.
    ///   - threadRoot: the top-level post of a loaded message (the message itself for a post);
    ///     nil when it is not loaded or its thread can't be resolved.
    static func make(
        runs: [ActivityRunLayout],
        statuses: [ActivityStatusLine],
        typers: [ChatTypingEntry],
        deletedMessageIds: Set<String>,
        isLoaded: (String) -> Bool,
        threadRoot: (String) -> String?
    ) -> DiscussionActivityPlacement {
        var placement = DiscussionActivityPlacement()

        for run in runs {
            if let closedBy = run.closedByMessageId {
                if !deletedMessageIds.contains(closedBy), isLoaded(closedBy) {
                    placement.attached[closedBy, default: []].append(run.id)
                }
                continue
            }
            let rootId = run.replyTo.flatMap(threadRoot)
            placement.updateBucket(rootId: rootId) { $0.runIds.append(run.id) }
        }

        for status in statuses {
            let rootId = status.replyTo.flatMap(threadRoot)
            placement.updateBucket(rootId: rootId) { $0.statusPublishers.append(status.publisher) }
        }

        for typer in typers {
            let rootId = typer.replyTo.flatMap(threadRoot)
            placement.updateBucket(rootId: rootId) { $0.typingIdentities.append(typer.identity) }
        }

        return placement
    }

    /// Thread roots with activity; a change here needs a list rebuild.
    var threadRootIds: Set<String> {
        Set(threads.keys)
    }

    private mutating func updateBucket(rootId: String?, _ update: (inout DiscussionActivityBucket) -> Void) {
        if let rootId {
            update(&threads[rootId, default: DiscussionActivityBucket()])
        } else {
            update(&root)
        }
    }
}
