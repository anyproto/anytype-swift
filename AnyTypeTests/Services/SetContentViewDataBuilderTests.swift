import Testing
import Foundation
@testable import Anytype
import Services
import SwiftProtobuf

@Suite
struct SetContentViewDataBuilderTests {

    private let builder: SetContentViewDataBuilder

    init() {
        Container.shared.propertyDetailsStorage.register { MockPropertyDetailsStorage() }
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

    // MARK: - Gallery cover: Picture property

    @Test("Picture cover resolves the picture property image")
    func testPictureCover_ImageInStorage_ReturnsImageCover() {
        let pictureId = "picture-image-1"
        let storage = ObjectDetailsStorage()
        storage.add(details: .mock(id: pictureId, layout: .image))
        let object = ObjectDetails.mock(id: "bookmark-1", layout: .bookmark, picture: pictureId)

        let result = cover(for: object, coverKey: SetViewSettingsImagePreviewCover.picture.rawValue, storage: storage)

        #expect(result == .cover(.imageId(pictureId)))
    }

    @Test("Picture cover returns nil when the picture property is empty")
    func testPictureCover_EmptyPicture_ReturnsNil() {
        let object = ObjectDetails.mock(id: "bookmark-1", layout: .bookmark)

        let result = cover(for: object, coverKey: SetViewSettingsImagePreviewCover.picture.rawValue, storage: ObjectDetailsStorage())

        #expect(result == nil)
    }

    @Test("Picture cover returns nil when the picture target is not an image")
    func testPictureCover_NonImageTarget_ReturnsNil() {
        let pictureId = "not-an-image"
        let storage = ObjectDetailsStorage()
        storage.add(details: .mock(id: pictureId, layout: .basic))
        let object = ObjectDetails.mock(id: "bookmark-1", layout: .bookmark, picture: pictureId)

        let result = cover(for: object, coverKey: SetViewSettingsImagePreviewCover.picture.rawValue, storage: storage)

        #expect(result == nil)
    }

    @Test("Picture cover returns nil when the picture target is missing from storage")
    func testPictureCover_TargetMissing_ReturnsNil() {
        let object = ObjectDetails.mock(id: "bookmark-1", layout: .bookmark, picture: "ghost-id")

        let result = cover(for: object, coverKey: SetViewSettingsImagePreviewCover.picture.rawValue, storage: ObjectDetailsStorage())

        #expect(result == nil)
    }

    @Test("None cover does not auto-show a bookmark picture")
    func testNoneCover_BookmarkWithPicture_ReturnsNil() {
        let pictureId = "picture-image-1"
        let storage = ObjectDetailsStorage()
        storage.add(details: .mock(id: pictureId, layout: .image))
        let object = ObjectDetails.mock(id: "bookmark-1", layout: .bookmark, picture: pictureId)

        let result = cover(for: object, coverKey: SetViewSettingsImagePreviewCover.none.rawValue, storage: storage)

        #expect(result == nil)
    }

    @Test("Non-gallery view returns nil cover")
    func testNonGalleryView_ReturnsNil() {
        let pictureId = "picture-image-1"
        let storage = ObjectDetailsStorage()
        storage.add(details: .mock(id: pictureId, layout: .image))
        let object = ObjectDetails.mock(id: "bookmark-1", layout: .bookmark, picture: pictureId)

        let result = cover(for: object, coverKey: SetViewSettingsImagePreviewCover.picture.rawValue, storage: storage, viewType: .list)

        #expect(result == nil)
    }

    // MARK: - Helpers

    private let spaceId = "space-1"

    private func cover(
        for object: ObjectDetails,
        coverKey: String,
        storage: ObjectDetailsStorage,
        viewType: DataviewViewType = .gallery
    ) -> ObjectHeaderCoverType? {
        let view = DataviewView.empty.updated(type: viewType, coverRelationKey: coverKey)
        return builder.coverType(object, dataView: .empty, activeView: view, spaceId: spaceId, detailsStorage: storage)
    }
}

extension ObjectDetails {
    static func mock(id: String, layout: DetailsLayout? = nil, picture: String? = nil) -> ObjectDetails {
        var values: [String: Google_Protobuf_Value] = [:]
        if let layout {
            values[BundledPropertyKey.resolvedLayout.rawValue] = layout.rawValue.protobufValue
        }
        if let picture {
            values[BundledPropertyKey.picture.rawValue] = picture.protobufValue
        }
        return ObjectDetails(id: id, values: values)
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
