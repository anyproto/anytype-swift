import Foundation
import Testing
@testable import Anytype

@Suite
struct TypingPublishPolicyTests {

    private let start = Date(timeIntervalSinceReferenceDate: 1_000)

    private func at(_ seconds: TimeInterval) -> Date {
        start.addingTimeInterval(seconds)
    }

    @Test func firstEditPublishesAtOnce() {
        var policy = TypingPublishPolicy(canPublish: true)
        #expect(policy.userEdited(isEmpty: false, replyTo: nil, now: at(0)) == TypingSignal(active: true, replyTo: nil))
    }

    @Test func continuedTypingRepublishesAtMostEveryTwoSeconds() {
        var policy = TypingPublishPolicy(canPublish: true)
        _ = policy.userEdited(isEmpty: false, replyTo: nil, now: at(0))
        #expect(policy.userEdited(isEmpty: false, replyTo: nil, now: at(1)) == nil)
        #expect(policy.userEdited(isEmpty: false, replyTo: nil, now: at(1.9)) == nil)
        #expect(policy.userEdited(isEmpty: false, replyTo: nil, now: at(2)) == TypingSignal(active: true, replyTo: nil))
    }

    @Test func stopsThreeSecondsAfterTheLastEdit() {
        var policy = TypingPublishPolicy(canPublish: true)
        _ = policy.userEdited(isEmpty: false, replyTo: nil, now: at(0))
        _ = policy.userEdited(isEmpty: false, replyTo: nil, now: at(1))
        #expect(policy.idleDeadline == at(4))
        #expect(policy.tick(now: at(3.9)) == nil)
        #expect(policy.tick(now: at(4)) == TypingSignal(active: false, replyTo: nil))
        // Nothing more is owed
        #expect(policy.tick(now: at(10)) == nil)
        #expect(policy.stop() == nil)
    }

    @Test func sendBlurLeaveOrBackgroundStopAtOnceOnlyWhenOwed() {
        var policy = TypingPublishPolicy(canPublish: true)
        #expect(policy.stop() == nil)
        _ = policy.userEdited(isEmpty: false, replyTo: nil, now: at(0))
        #expect(policy.stop() == TypingSignal(active: false, replyTo: nil))
        #expect(policy.stop() == nil)
    }

    @Test func emptiedComposerStops() {
        var policy = TypingPublishPolicy(canPublish: true)
        _ = policy.userEdited(isEmpty: false, replyTo: nil, now: at(0))
        #expect(policy.userEdited(isEmpty: true, replyTo: nil, now: at(0.5)) == TypingSignal(active: false, replyTo: nil))
    }

    @Test func emptyEditWithoutTypingPublishesNothing() {
        var policy = TypingPublishPolicy(canPublish: true)
        #expect(policy.userEdited(isEmpty: true, replyTo: nil, now: at(0)) == nil)
    }

    @Test func replyTargetChangeRepublishesAtOnce() {
        var policy = TypingPublishPolicy(canPublish: true)
        _ = policy.userEdited(isEmpty: false, replyTo: nil, now: at(0))
        #expect(policy.replyTargetChanged("post", now: at(0.5)) == TypingSignal(active: true, replyTo: "post"))
        #expect(policy.replyTargetChanged("post", now: at(0.6)) == nil)
    }

    @Test func replyTargetChangeWithoutTypingPublishesNothing() {
        var policy = TypingPublishPolicy(canPublish: true)
        #expect(policy.replyTargetChanged("post", now: at(0)) == nil)
    }

    @Test func editWithNewReplyTargetBypassesTheThrottle() {
        var policy = TypingPublishPolicy(canPublish: true)
        _ = policy.userEdited(isEmpty: false, replyTo: nil, now: at(0))
        #expect(policy.userEdited(isEmpty: false, replyTo: "post", now: at(0.5)) == TypingSignal(active: true, replyTo: "post"))
    }

    @Test func settingOffPublishesNothing() {
        var policy = TypingPublishPolicy(canPublish: false)
        #expect(policy.userEdited(isEmpty: false, replyTo: nil, now: at(0)) == nil)
        #expect(policy.tick(now: at(5)) == nil)
    }

    @Test func turningOffMidTypingSendsTheOwedStopOnce() {
        var policy = TypingPublishPolicy(canPublish: true)
        _ = policy.userEdited(isEmpty: false, replyTo: nil, now: at(0))
        #expect(policy.setCanPublish(false) == TypingSignal(active: false, replyTo: nil))
        #expect(policy.userEdited(isEmpty: false, replyTo: nil, now: at(1)) == nil)
        #expect(policy.tick(now: at(10)) == nil)
    }
}

@Suite
struct TypingRosterTests {

    private let start = Date(timeIntervalSinceReferenceDate: 1_000)
    private let ownSession = "own-session"
    private let ownIdentity = "me"

    private func at(_ seconds: TimeInterval) -> Date {
        start.addingTimeInterval(seconds)
    }

    private func apply(
        _ roster: inout TypingRoster,
        identity: String,
        session: String = "s1",
        active: Bool = true,
        replyTo: String? = nil,
        blockId: String? = nil,
        at seconds: TimeInterval = 0
    ) -> Bool {
        roster.apply(
            ChatTypingPayload(sessionId: session, active: active, replyTo: replyTo, blockId: blockId),
            identity: identity,
            ownSessionId: ownSession,
            ownIdentity: ownIdentity,
            now: at(seconds)
        )
    }

    @Test func dropsOwnEchoOwnAccountAndEditorPresence() {
        var roster = TypingRoster()
        #expect(!apply(&roster, identity: "anna", session: ownSession))
        // The own account on another device is not shown as typing
        #expect(!apply(&roster, identity: ownIdentity, session: "other-device"))
        #expect(!apply(&roster, identity: "anna", blockId: "block"))
        #expect(roster.typers().isEmpty)
    }

    @Test func activeFalseRemovesTheEntry() {
        var roster = TypingRoster()
        _ = apply(&roster, identity: "anna")
        #expect(apply(&roster, identity: "anna", active: false))
        #expect(roster.typers().isEmpty)
    }

    @Test func expiresFiveSecondsAfterTheLastRefresh() {
        var roster = TypingRoster()
        _ = apply(&roster, identity: "anna", at: 0)
        _ = apply(&roster, identity: "anna", at: 2)
        let sweptEarly = roster.sweep(now: at(6.9))
        #expect(!sweptEarly)
        let sweptAtExpiry = roster.sweep(now: at(7))
        #expect(sweptAtExpiry)
        #expect(roster.typers().isEmpty)
    }

    @Test func showsOnePersonOnceWithTheLatestReplyTarget() {
        var roster = TypingRoster()
        _ = apply(&roster, identity: "anna", session: "phone", replyTo: "post-1", at: 0)
        _ = apply(&roster, identity: "ben", at: 0.5)
        _ = apply(&roster, identity: "anna", session: "laptop", replyTo: "post-2", at: 1)
        #expect(roster.typers() == [
            ChatTypingEntry(identity: "anna", replyTo: "post-2"),
            ChatTypingEntry(identity: "ben", replyTo: nil)
        ])
    }

    @Test func aMessageFromThatIdentityClearsIt() {
        var roster = TypingRoster()
        _ = apply(&roster, identity: "anna", session: "phone")
        _ = apply(&roster, identity: "anna", session: "laptop")
        let cleared = roster.clear(identity: "anna")
        #expect(cleared)
        #expect(roster.typers().isEmpty)
    }

    @Test func refreshWithSameStateIsNotAVisibleChange() {
        var roster = TypingRoster()
        #expect(apply(&roster, identity: "anna", at: 0))
        #expect(!apply(&roster, identity: "anna", at: 2))
        #expect(apply(&roster, identity: "anna", replyTo: "post", at: 3))
    }

    @Test func stoppingOneSessionKeepsTheOther() {
        var roster = TypingRoster()
        _ = apply(&roster, identity: "anna", session: "phone", replyTo: "post-1", at: 0)
        _ = apply(&roster, identity: "anna", session: "laptop", replyTo: "post-2", at: 1)
        _ = apply(&roster, identity: "anna", session: "laptop", active: false, at: 2)
        #expect(roster.typers() == [ChatTypingEntry(identity: "anna", replyTo: "post-1")])
        let swept = roster.sweep(now: at(5))
        #expect(swept)
        #expect(roster.typers().isEmpty)
    }
}

@MainActor
final class ChatActivityStoreMock: ChatActivityStoreProtocol {
    var sendTypingEnabled = true
    private(set) var published: [(objectId: String, signal: TypingSignal)] = []

    func setSendTypingEnabled(_ enabled: Bool) {
        sendTypingEnabled = enabled
    }
    func attach(spaceId: String, chatId: String, mode: ChatActivityMode) -> ChatActivityState? { nil }
    func detach(_ state: ChatActivityState) {}
    func observeTail(_ message: ActivityObservedMessage?, in state: ChatActivityState) {}
    func registerTypingPublisher(_ publisher: ChatTypingPublisher) {}
    func publishTyping(spaceId: String, objectId: String, signal: TypingSignal) {
        published.append((objectId, signal))
    }
    func clearAll() {}
}

@Suite
@MainActor
struct ChatTypingPublisherTests {

    private let store = ChatActivityStoreMock()

    private func makePublisher(objectId: String? = "chat") -> ChatTypingPublisher {
        let publisher = ChatTypingPublisher(spaceId: "space", objectId: objectId, store: store)
        publisher.setAttached(true)
        publisher.setCanEdit(true)
        return publisher
    }

    private var signals: [TypingSignal] {
        store.published.map(\.signal)
    }

    @Test func publishesOnUserEditsAndStopsOnce() {
        let publisher = makePublisher()
        publisher.userEditedText(isEmpty: false)
        publisher.userEditedText(isEmpty: false)
        publisher.stop()
        publisher.stop()
        #expect(signals == [TypingSignal(active: true, replyTo: nil), TypingSignal(active: false, replyTo: nil)])
        #expect(store.published.allSatisfy { $0.objectId == "chat" })
    }

    @Test func nothingWithoutWriteRightsOrBeforeTheDiscussionExists() {
        let reader = ChatTypingPublisher(spaceId: "space", objectId: "chat", store: store)
        reader.setAttached(true)
        reader.userEditedText(isEmpty: false)
        let undiscussed = makePublisher(objectId: nil)
        undiscussed.userEditedText(isEmpty: false)
        #expect(store.published.isEmpty)
    }

    @Test func editingAnExistingMessageEndsTyping() {
        let publisher = makePublisher()
        publisher.userEditedText(isEmpty: false)
        publisher.setEditingMessage(true)
        publisher.userEditedText(isEmpty: false)
        #expect(signals == [TypingSignal(active: true, replyTo: nil), TypingSignal(active: false, replyTo: nil)])
    }

    // Acceptance: with the setting off, nothing is published; a stop already owed still goes out
    @Test func turningTheSettingOffSendsTheOwedStop() {
        let publisher = makePublisher()
        publisher.userEditedText(isEmpty: false)
        store.setSendTypingEnabled(false)
        publisher.settingChanged()
        publisher.userEditedText(isEmpty: false)
        #expect(signals == [TypingSignal(active: true, replyTo: nil), TypingSignal(active: false, replyTo: nil)])
    }

    @Test func replyTargetTravelsWithTyping() {
        let publisher = makePublisher(objectId: "discussion")
        publisher.setReplyTo("post")
        publisher.userEditedText(isEmpty: false)
        publisher.setReplyTo(nil)
        #expect(signals == [TypingSignal(active: true, replyTo: "post"), TypingSignal(active: true, replyTo: nil)])
    }

    @Test func leavingTheScreenStopsTyping() {
        let publisher = makePublisher()
        publisher.userEditedText(isEmpty: false)
        publisher.setAttached(false)
        #expect(signals.last == TypingSignal(active: false, replyTo: nil))
    }
}
