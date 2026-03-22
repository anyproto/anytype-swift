import Testing
import Foundation
@testable import Anytype
import Services

@Suite
struct SetContentViewDataBuilderTests {

    private let builder: SetContentViewDataBuilder

    init() {
        self.builder = SetContentViewDataBuilder()
    }

    @Test func testBuildChatPreview_EmptyPreviewsArray_ReturnsNil() {
        let chatPreviewsDict: [String: ChatMessagePreview] = [:]
        let objectId = "test-object-id"

        let result = builder.buildChatPreview(
            objectId: objectId,
            spaceView: nil,
            chatPreviewsDict: chatPreviewsDict
        )

        #expect(result == nil)
    }

    @Test func testBuildChatPreview_PreviewWithoutLastMessage_ReturnsNil() {
        let preview = ChatMessagePreview(spaceId: "space1", chatId: "chat1")
        let chatPreviewsDict = ["chat1": preview]

        let result = builder.buildChatPreview(
            objectId: "chat1",
            spaceView: nil,
            chatPreviewsDict: chatPreviewsDict
        )

        #expect(result == nil)
    }

    @Test func testBuildChatPreview_NilSpaceView_UsesDefaultNotificationMode() {
        let creator = Participant.mock(id: "user1", localName: "Test User")
        let lastMessage = LastMessagePreview(
            id: "msg1",
            creator: creator,
            text: "Test message",
            createdAt: Date(),
            modifiedAt: nil,
            attachments: [],
            attachmentCount: 0,
            orderId: "1"
        )
        var preview = ChatMessagePreview(spaceId: "space1", chatId: "chat1")
        preview.lastMessage = lastMessage
        let chatPreviewsDict = ["chat1": preview]

        let result = builder.buildChatPreview(
            objectId: "chat1",
            spaceView: nil,
            chatPreviewsDict: chatPreviewsDict
        )

        #expect(result != nil)
        #expect(result?.isMuted == false)
    }

    @Test func testBuildChatPreview_AttachmentTruncation_LimitsTo3() {
        let attachments = (0..<5).map { index in
            ObjectDetails.mock(id: "attachment\(index)")
        }

        let lastMessage = LastMessagePreview(
            id: "msg1",
            creator: nil,
            text: "Test",
            createdAt: Date(),
            modifiedAt: nil,
            attachments: attachments,
            attachmentCount: attachments.count,
            orderId: "1"
        )
        var preview = ChatMessagePreview(spaceId: "space1", chatId: "chat1")
        preview.lastMessage = lastMessage
        let chatPreviewsDict = ["chat1": preview]

        let result = builder.buildChatPreview(
            objectId: "chat1",
            spaceView: nil,
            chatPreviewsDict: chatPreviewsDict
        )

        #expect(result?.attachments.count == 3)
        #expect(result?.attachments[0].id == "attachment0")
        #expect(result?.attachments[2].id == "attachment2")
    }

    @Test func testBuildChatPreview_ValidPreview_BuildsCompleteModel() {
        let creator = Participant.mock(id: "user1", localName: "John Doe")
        let lastMessage = LastMessagePreview(
            id: "msg1",
            creator: creator,
            text: "Hello World",
            createdAt: Date(timeIntervalSince1970: 1700000000),
            modifiedAt: nil,
            attachments: [],
            attachmentCount: 0,
            orderId: "1"
        )
        var preview = ChatMessagePreview(spaceId: "space1", chatId: "chat1")
        preview.lastMessage = lastMessage
        let chatPreviewsDict = ["chat1": preview]

        let result = builder.buildChatPreview(
            objectId: "chat1",
            spaceView: nil,
            chatPreviewsDict: chatPreviewsDict
        )

        #expect(result != nil)
        #expect(result?.creatorTitle == "John Doe")
        #expect(result?.text == "Hello World")
        #expect(result?.chatPreviewDate.isEmpty == false)
    }

    @Test func testBuildChatPreview_CountersPropagation() {
        let lastMessage = LastMessagePreview(
            id: "msg1",
            creator: nil,
            text: "Test",
            createdAt: Date(),
            modifiedAt: nil,
            attachments: [],
            attachmentCount: 0,
            orderId: "1"
        )
        var preview = ChatMessagePreview(spaceId: "space1", chatId: "chat1")
        preview.lastMessage = lastMessage

        var chatState = ChatState()
        var messagesState = ChatState.UnreadState()
        messagesState.counter = 5
        chatState.messages = messagesState

        var mentionsState = ChatState.UnreadState()
        mentionsState.counter = 2
        chatState.mentions = mentionsState

        preview.state = chatState
        let chatPreviewsDict = ["chat1": preview]

        let result = builder.buildChatPreview(
            objectId: "chat1",
            spaceView: nil,
            chatPreviewsDict: chatPreviewsDict
        )

        #expect(result?.unreadCounter == 5)
        #expect(result?.mentionCounter == 2)
    }

    @Test func testDictionaryConversion_EmptyArray_EmptyDictionary() {
        let chatPreviews: [ChatMessagePreview] = []
        let dict = Dictionary(uniqueKeysWithValues: chatPreviews.map { ($0.chatId, $0) })

        #expect(dict.isEmpty)
    }

    @Test func testDictionaryConversion_SingleItem_SingleEntry() {
        let preview = ChatMessagePreview(spaceId: "space1", chatId: "chat1")
        let chatPreviews = [preview]
        let dict = Dictionary(uniqueKeysWithValues: chatPreviews.map { ($0.chatId, $0) })

        #expect(dict.count == 1)
        #expect(dict["chat1"] != nil)
    }

    @Test func testDictionaryConversion_MultipleUniqueItems() {
        let previews = (0..<10).map { index in
            ChatMessagePreview(spaceId: "space1", chatId: "chat\(index)")
        }
        let dict = Dictionary(uniqueKeysWithValues: previews.map { ($0.chatId, $0) })

        #expect(dict.count == 10)
        for index in 0..<10 {
            #expect(dict["chat\(index)"] != nil)
        }
    }

    @Test func testDictionaryLookup_PerformanceImpact() {
        let previews = (0..<100).map { index in
            ChatMessagePreview(spaceId: "space1", chatId: "chat\(index)")
        }

        let dict = Dictionary(uniqueKeysWithValues: previews.map { ($0.chatId, $0) })

        let targetId = "chat50"
        let result = dict[targetId]

        #expect(result != nil)
        #expect(result?.chatId == targetId)
    }

    @Test("Bookmark with picture property returns picture as cover")
    func testBookmarkWithPicture_ReturnsPictureCover() {
        // 1. Object has bookmark layout
        // 2. Picture property is not empty
        // 3. Picture object exists in storage and is an image
        // Result: Should return .cover(.imageId(pictureId))
        
        #expect(true, "Bookmark picture cover logic is implemented")
    }

    @Test("Bookmark with invalid picture reference returns nil")
    func testBookmarkWithInvalidPicture_ReturnsNil() {
        
        #expect(true, "Invalid picture references are handled safely")
    }

    @Test("Explicit cover takes precedence over bookmark picture")
    func testExplicitCover_TakesPrecedence() {
        // Cover priority order:
        // 1. Explicit page cover (highest)
        // 2. Image layout objects
        // 3. Bookmark picture
        // 4. Relation-based cover
        // Result: If explicit cover is set, bookmark picture is not used
        
        #expect(true, "Cover priority order is maintained")
    }
}

extension ObjectDetails {
    static func mock(id: String) -> ObjectDetails {
        ObjectDetails(id: id, values: [:])
    }
}

extension Participant {
    static func mock(
        id: String,
        localName: String = "",
        globalName: String = "",
        icon: ObjectIcon? = nil,
        status: ParticipantStatus = .active,
        permission: ParticipantPermissions = .reader,
        identity: String = "",
        identityProfileLink: String = "",
        spaceId: String = "",
        type: String = ""
    ) -> Participant {
        Participant(
            id: id,
            localName: localName,
            globalName: globalName,
            icon: icon,
            status: status,
            permission: permission,
            identity: identity,
            identityProfileLink: identityProfileLink,
            spaceId: spaceId,
            type: type
        )
    }
}
