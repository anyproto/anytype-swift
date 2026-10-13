import Foundation

/// Publishes the typing state of one composer. Feed it user edits only: cursor moves, focus,
/// a restored draft or programmatic text never count.
@MainActor
final class ChatTypingPublisher {

    private let spaceId: String
    private let store: any ChatActivityStoreProtocol
    private var objectId: String?
    private var policy = TypingPublishPolicy()
    private var replyTo: String?
    private var isAttached = false
    private var canEdit = false
    private var isEditingMessage = false
    private var idleTask: Task<Void, Never>?

    init(spaceId: String, objectId: String?, store: any ChatActivityStoreProtocol) {
        self.spaceId = spaceId
        self.objectId = objectId
        self.store = store
        store.registerTypingPublisher(self)
    }

    /// Discussions get their id when the first comment creates them.
    func setObjectId(_ objectId: String?) {
        guard self.objectId != objectId else { return }
        stop()
        self.objectId = objectId
        refreshCanPublish()
    }

    /// True while the screen is on screen and subscribed.
    func setAttached(_ attached: Bool) {
        isAttached = attached
        refreshCanPublish()
    }

    func setCanEdit(_ canEdit: Bool) {
        self.canEdit = canEdit
        refreshCanPublish()
    }

    /// Never publish while editing an existing message.
    func setEditingMessage(_ isEditing: Bool) {
        isEditingMessage = isEditing
        refreshCanPublish()
    }

    func settingChanged() {
        refreshCanPublish()
    }

    func userEditedText(isEmpty: Bool) {
        publish(policy.userEdited(isEmpty: isEmpty, replyTo: replyTo, now: Date()))
    }

    /// Discussions: the post a reply composer answers; nil for the main composer.
    func setReplyTo(_ replyTo: String?) {
        guard self.replyTo != replyTo else { return }
        self.replyTo = replyTo
        publish(policy.replyTargetChanged(replyTo, now: Date()))
    }

    /// Send, blur, leaving the screen, backgrounding. Publishes a stop only when one is owed.
    func stop() {
        publish(policy.stop())
    }

    // MARK: - Private

    /// The feature flag is enforced by the store: with it off nothing attaches.
    private func refreshCanPublish() {
        let canPublish = store.sendTypingEnabled
            && isAttached
            && canEdit
            && !isEditingMessage
            && objectId != nil
        publish(policy.setCanPublish(canPublish))
    }

    private func publish(_ signal: TypingSignal?) {
        if let signal, let objectId {
            store.publishTyping(spaceId: spaceId, objectId: objectId, signal: signal)
        }
        scheduleIdleStopIfNeeded()
    }

    /// One pending task at a time: it sleeps until the idle deadline, which later edits push back.
    private func scheduleIdleStopIfNeeded() {
        guard idleTask == nil, policy.idleDeadline != nil else { return }
        idleTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let deadline = self?.policy.idleDeadline else { break }
                let delay = deadline.timeIntervalSinceNow
                if delay > 0 {
                    try? await Task.sleep(for: .seconds(delay))
                    continue
                }
                self?.tick()
                break
            }
            self?.idleTask = nil
        }
    }

    private func tick() {
        guard let signal = policy.tick(now: Date()), let objectId else { return }
        store.publishTyping(spaceId: spaceId, objectId: objectId, signal: signal)
    }
}
