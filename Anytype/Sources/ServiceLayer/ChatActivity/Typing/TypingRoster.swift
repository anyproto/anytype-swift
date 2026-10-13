import Foundation

struct ChatTypingEntry: Equatable, Sendable {
    let identity: String
    let replyTo: String?
}

/// Receiver-side typing state for one chat or discussion. Pure: entries are stamped with the
/// receiver's own clock and expire 5 s after their last refresh.
struct TypingRoster {

    static let entryLifetime: TimeInterval = 5

    private struct Entry: Equatable {
        let identity: String
        let sessionId: String
        var replyTo: String?
        var lastSeen: Date
    }

    private var entries: [Entry] = []

    var isEmpty: Bool {
        entries.isEmpty
    }

    /// Applies one received payload. `identity` is the event's verified sender, never a payload field.
    /// Returns true when the visible state changed.
    mutating func apply(
        _ payload: ChatTypingPayload,
        identity: String,
        ownSessionId: String,
        ownIdentity: String?,
        now: Date
    ) -> Bool {
        // Own echo, own account on any device, and editor presence never show here
        guard payload.sessionId != ownSessionId,
              identity != ownIdentity,
              payload.blockId == nil else { return false }

        let index = entries.firstIndex { $0.identity == identity && $0.sessionId == payload.sessionId }

        guard payload.active else {
            guard let index else { return false }
            entries.remove(at: index)
            return true
        }

        if let index {
            let changed = entries[index].replyTo != payload.replyTo
            entries[index].replyTo = payload.replyTo
            entries[index].lastSeen = now
            return changed
        }

        entries.append(Entry(identity: identity, sessionId: payload.sessionId, replyTo: payload.replyTo, lastSeen: now))
        return true
    }

    /// A message from that identity arrived: the data beats the signal.
    mutating func clear(identity: String) -> Bool {
        let count = entries.count
        entries.removeAll { $0.identity == identity }
        return entries.count != count
    }

    mutating func sweep(now: Date) -> Bool {
        let count = entries.count
        entries.removeAll { now.timeIntervalSince($0.lastSeen) >= Self.entryLifetime }
        return entries.count != count
    }

    /// One entry per identity, in first-seen order, whatever its session count. The reply target
    /// comes from that identity's most recently refreshed session.
    func typers(hiding hidden: Set<String> = []) -> [ChatTypingEntry] {
        var order: [String] = []
        var latest: [String: Entry] = [:]
        for entry in entries where !hidden.contains(entry.identity) {
            if let current = latest[entry.identity] {
                if entry.lastSeen > current.lastSeen {
                    latest[entry.identity] = entry
                }
            } else {
                order.append(entry.identity)
                latest[entry.identity] = entry
            }
        }
        return order.compactMap { identity in
            latest[identity].map { ChatTypingEntry(identity: identity, replyTo: $0.replyTo) }
        }
    }
}
