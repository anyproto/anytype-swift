import Foundation

struct TypingSignal: Equatable, Sendable {
    let active: Bool
    let replyTo: String?
}

/// When a composer publishes typing state. Pure: the caller supplies the clock and performs
/// the returned signal.
///
/// - The first text change publishes `active:true` at once; continued typing republishes at
///   most every 2 s; a changed reply target republishes at once.
/// - 3 s without a text change, an emptied composer, or `stop()` (send, blur, leave,
///   background) publish `active:false` — only when one is owed.
/// - With `canPublish` off nothing new goes out; a stop already owed still does.
struct TypingPublishPolicy {

    static let refreshInterval: TimeInterval = 2
    static let idleTimeout: TimeInterval = 3

    private(set) var canPublish: Bool
    private var lastSent: TypingSignal?
    private var lastPublishAt: Date?
    private var lastEditAt: Date?

    init(canPublish: Bool = false) {
        self.canPublish = canPublish
    }

    var owesStop: Bool {
        lastSent?.active == true
    }

    /// When `tick` should run next to send the idle stop.
    var idleDeadline: Date? {
        guard owesStop, let lastEditAt else { return nil }
        return lastEditAt.addingTimeInterval(Self.idleTimeout)
    }

    mutating func userEdited(isEmpty: Bool, replyTo: String?, now: Date) -> TypingSignal? {
        lastEditAt = now
        guard canPublish else { return nil }
        if isEmpty {
            return stop()
        }
        if !owesStop || lastSent?.replyTo != replyTo {
            return start(replyTo: replyTo, now: now)
        }
        if let lastPublishAt, now.timeIntervalSince(lastPublishAt) >= Self.refreshInterval {
            return start(replyTo: replyTo, now: now)
        }
        return nil
    }

    mutating func replyTargetChanged(_ replyTo: String?, now: Date) -> TypingSignal? {
        guard canPublish, owesStop, lastSent?.replyTo != replyTo else { return nil }
        return start(replyTo: replyTo, now: now)
    }

    mutating func tick(now: Date) -> TypingSignal? {
        guard let idleDeadline, now >= idleDeadline else { return nil }
        return stop()
    }

    mutating func stop() -> TypingSignal? {
        guard owesStop else { return nil }
        let signal = TypingSignal(active: false, replyTo: nil)
        lastSent = signal
        return signal
    }

    mutating func setCanPublish(_ value: Bool) -> TypingSignal? {
        canPublish = value
        return value ? nil : stop()
    }

    private mutating func start(replyTo: String?, now: Date) -> TypingSignal {
        let signal = TypingSignal(active: true, replyTo: replyTo)
        lastSent = signal
        lastPublishAt = now
        return signal
    }
}
