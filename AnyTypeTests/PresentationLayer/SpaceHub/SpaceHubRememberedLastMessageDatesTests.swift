import Testing
import Foundation
@testable import Anytype
import Services
import SwiftProtobuf

// Chat previews stream in after launch. Until a space's previews arrive the hub keeps it at the
// message date it showed last time; once they arrive they are the truth, even with no message.
struct SpaceHubRememberedLastMessageDatesTests {

    private let day: TimeInterval = 86_400
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    // MARK: - Fallback while previews are loading

    @Test func spaceWithoutPreviewUsesRememberedDate() {
        let remembered = now - 1 * day

        let result = build(spaces: [makeSpace(id: "space-1")], remembered: ["space-1": remembered])

        #expect(result.spaces.map(\.lastMessageDate) == [remembered])
        #expect(result.arrivedLastMessageDates.isEmpty)
    }

    @Test func arrivedPreviewWinsOverRememberedDate() {
        let messageDate = now - 1 * day

        let result = build(
            spaces: [makeSpace(id: "space-1")],
            previews: [makePreview(spaceId: "space-1", chatId: "chat-1", messageDate: messageDate)],
            chatDetails: [makeChat(id: "chat-1")],
            remembered: ["space-1": now - 5 * day]
        )

        #expect(result.spaces.map(\.lastMessageDate) == [messageDate])
        #expect(result.arrivedLastMessageDates == ["space-1": messageDate])
    }

    @Test func arrivedPreviewWithoutMessageDropsRememberedDate() {
        // The chat's state arrived but it holds no message: emptied, or never had one.
        let remembered = ["space-1": now - 1 * day]

        let result = build(
            spaces: [makeSpace(id: "space-1")],
            previews: [ChatMessagePreview(spaceId: "space-1", chatId: "chat-1")],
            chatDetails: [makeChat(id: "chat-1")],
            remembered: remembered
        )
        let updated = SpaceHubSpacesStorage.rememberedLastMessageDates(remembered, updatedWith: result.arrivedLastMessageDates)

        #expect(result.spaces.map(\.lastMessageDate) == [nil])
        #expect(result.arrivedLastMessageDates.keys.contains("space-1"))
        #expect(updated.isEmpty)
    }

    @Test func archivedChatCountsAsArrivedWithoutMessage() {
        let remembered = ["space-1": now - 1 * day]

        let result = build(
            spaces: [makeSpace(id: "space-1")],
            previews: [makePreview(spaceId: "space-1", chatId: "chat-1", messageDate: now - 1 * day)],
            chatDetails: [makeChat(id: "chat-1", isArchived: true)],
            remembered: remembered
        )
        let updated = SpaceHubSpacesStorage.rememberedLastMessageDates(remembered, updatedWith: result.arrivedLastMessageDates)

        #expect(result.spaces.map(\.lastMessageDate) == [nil])
        #expect(updated.isEmpty)
    }

    @Test func spaceNeverSeenBeforeHasNoDate() {
        let result = build(spaces: [makeSpace(id: "space-1")], remembered: [:])

        #expect(result.spaces.map(\.lastMessageDate) == [nil])
    }

    // MARK: - Remembering dates for the next launch

    @Test func partialPreviewSetKeepsDatesOfSpacesStillLoading() {
        let remembered = ["loading": now - 3 * day, "arrived": now - 4 * day]
        let arrivedMessageDate = now - 1 * day

        let result = build(
            spaces: [makeSpace(id: "loading"), makeSpace(id: "arrived")],
            previews: [makePreview(spaceId: "arrived", chatId: "chat-1", messageDate: arrivedMessageDate)],
            chatDetails: [makeChat(id: "chat-1")],
            remembered: remembered
        )
        let updated = SpaceHubSpacesStorage.rememberedLastMessageDates(remembered, updatedWith: result.arrivedLastMessageDates)

        #expect(updated == ["loading": now - 3 * day, "arrived": arrivedMessageDate])
    }

    @Test func newSpaceWithPreviewIsRemembered() {
        let messageDate = now - 1 * day

        let result = build(
            spaces: [makeSpace(id: "space-1")],
            previews: [makePreview(spaceId: "space-1", chatId: "chat-1", messageDate: messageDate)],
            chatDetails: [makeChat(id: "chat-1")],
            remembered: [:]
        )
        let updated = SpaceHubSpacesStorage.rememberedLastMessageDates([:], updatedWith: result.arrivedLastMessageDates)

        #expect(updated == ["space-1": messageDate])
    }

    // MARK: - Sorting

    @Test func rememberedDateOrdersSpaceAheadOfNewerJoinDate() {
        // "loading" joined long ago but its last message was yesterday; "joined" has no
        // messages and joined three days ago. Without the remembered date "loading" would
        // sort below "joined" and jump above it once its preview arrived.
        let loading = build(
            spaces: [makeSpace(id: "loading", joinDate: now - 30 * day)],
            remembered: ["loading": now - 1 * day]
        ).spaces
        let joined = build(
            spaces: [makeSpace(id: "joined", joinDate: now - 3 * day)],
            remembered: [:]
        ).spaces

        let sorted = (joined + loading).sortedForSpaceHub()

        #expect(sorted.map(\.spaceView.targetSpaceId) == ["loading", "joined"])
    }

    // MARK: - Fixtures

    private func build(
        spaces: [ParticipantSpaceViewData],
        previews: [ChatMessagePreview] = [],
        chatDetails: [ObjectDetails] = [],
        remembered: [String: Date]
    ) -> SpaceHubSpacesStorage.BuildResult {
        SpaceHubSpacesStorage.build(
            spaces: spaces,
            previews: previews,
            chatDetails: chatDetails,
            discussionUnreadBySpace: [:],
            rememberedLastMessageDates: remembered
        )
    }

    // The space view id and the target space id differ in production; keep them distinct so a
    // read/write key mismatch would fail here.
    private func makeSpace(id: String, joinDate: Date? = nil) -> ParticipantSpaceViewData {
        let spaceView = SpaceView(
            id: "view-\(id)",
            name: id,
            description: "",
            objectIconImage: .object(.space(.mock)),
            targetSpaceId: id,
            createdDate: nil,
            joinDate: joinDate,
            accountStatus: .spaceActive,
            localStatus: .ok,
            spaceAccessType: .private,
            readersLimit: nil,
            writersLimit: nil,
            chatId: "",
            spaceOrder: "",
            spaceType: .regular,
            pushNotificationEncryptionKey: "",
            pushNotificationMode: .all,
            forceAllIds: [],
            forceMuteIds: [],
            forceMentionIds: [],
            oneToOneIdentity: "",
            homepage: .empty
        )
        return ParticipantSpaceViewData(
            spaceView: spaceView,
            participant: nil,
            permissions: SpacePermissions(spaceView: spaceView, participant: nil, isLocalMode: false)
        )
    }

    private func makeChat(id: String, isArchived: Bool = false) -> ObjectDetails {
        var values: [String: Google_Protobuf_Value] = [:]
        if isArchived {
            values[BundledPropertyKey.isArchived.rawValue] = Google_Protobuf_Value(boolValue: true)
        }
        return ObjectDetails(id: id, values: values)
    }

    private func makePreview(spaceId: String, chatId: String, messageDate: Date) -> ChatMessagePreview {
        var preview = ChatMessagePreview(spaceId: spaceId, chatId: chatId)
        preview.lastMessage = LastMessagePreview(
            id: "message-\(chatId)",
            creator: nil,
            text: "Hello",
            createdAt: messageDate,
            modifiedAt: nil,
            attachments: [],
            attachmentCount: 0,
            orderId: "order-1"
        )
        return preview
    }
}
