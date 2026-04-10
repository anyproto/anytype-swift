import Testing
import Foundation
@testable import Anytype

@Suite
struct DiscussionCoordinatorDataCodableTests {

    // MARK: - Backward compatibility

    @Test
    func decodeLegacyPayloadWithoutMessageId() throws {
        // Pre-change JSON that does not include the messageId field
        let json = """
        {
            "discussionId": "disc-123",
            "objectId": "obj-456",
            "objectName": "My Object",
            "spaceId": "space-789"
        }
        """.data(using: .utf8)!

        let data = try JSONDecoder().decode(DiscussionCoordinatorData.self, from: json)
        #expect(data.discussionId == "disc-123")
        #expect(data.objectId == "obj-456")
        #expect(data.objectName == "My Object")
        #expect(data.spaceId == "space-789")
        #expect(data.messageId == nil)
    }

    // MARK: - Round-trip

    @Test
    func roundTripWithMessageId() throws {
        let original = DiscussionCoordinatorData(
            discussionId: "disc-123",
            objectId: "obj-456",
            objectName: "My Object",
            spaceId: "space-789",
            messageId: "msg-001"
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DiscussionCoordinatorData.self, from: encoded)

        #expect(decoded == original)
        #expect(decoded.messageId == "msg-001")
    }

    @Test
    func roundTripWithoutMessageId() throws {
        let original = DiscussionCoordinatorData(
            discussionId: "disc-123",
            objectId: "obj-456",
            objectName: "My Object",
            spaceId: "space-789"
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DiscussionCoordinatorData.self, from: encoded)

        #expect(decoded == original)
        #expect(decoded.messageId == nil)
    }

    @Test
    func roundTripWithNilDiscussionId() throws {
        let original = DiscussionCoordinatorData(
            discussionId: nil,
            objectId: "obj-456",
            objectName: "My Object",
            spaceId: "space-789",
            messageId: "msg-001"
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DiscussionCoordinatorData.self, from: encoded)

        #expect(decoded == original)
        #expect(decoded.discussionId == nil)
        #expect(decoded.messageId == "msg-001")
    }
}
