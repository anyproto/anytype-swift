import Foundation
import Testing
@testable import Anytype

@Suite
struct ActivityJSONTests {

    @Test func keepsKeyOrderAndNumberLexemes() throws {
        let json = try #require(ActivityJSON.parse(#"{"z":1,"a":12345678901234567890123,"m":1.50e+3}"#))
        #expect(json.fields?.map(\.key) == ["z", "a", "m"])
        #expect(json["a"] == .number("12345678901234567890123"))
        #expect(json.serialized() == #"{"z":1,"a":12345678901234567890123,"m":1.50e+3}"#)
    }

    @Test func preservesUnicodeZeroWidthAndEscapes() throws {
        let source = #"{"s":"a\nb​c\"d\\e 😀 😀"}"#
        let json = try #require(ActivityJSON.parse(source))
        #expect(json["s"]?.stringValue == "a\nb\u{200B}c\"d\\e 😀 😀")
        let roundTrip = try #require(ActivityJSON.parse(json.serialized()))
        #expect(roundTrip == json)
    }

    @Test func duplicateKeyKeepsFirstPositionAndLastValue() throws {
        let json = try #require(ActivityJSON.parse(#"{"a":1,"b":2,"a":3}"#))
        #expect(json.fields?.map(\.key) == ["a", "b"])
        #expect(json["a"] == .number("3"))
    }

    @Test(arguments: [
        "",
        "{",
        #"{"a":}"#,
        #"{"a":1,}"#,
        "[1 2]",
        "01",
        "1.",
        "tru",
        "\"raw\ncontrol\"",
        #"{"a":1} trailing"#
    ])
    func rejectsMalformedInput(_ source: String) {
        #expect(ActivityJSON.parse(source) == nil)
    }

    @Test func capsNestingDepth() {
        let deep = String(repeating: "[", count: 129) + String(repeating: "]", count: 129)
        let allowed = String(repeating: "[", count: 128) + String(repeating: "]", count: 128)
        #expect(ActivityJSON.parse(deep) == nil)
        #expect(ActivityJSON.parse(allowed) != nil)
    }

    @Test func rejectsPayloadsOverTheTransportLimit() {
        let text = String(repeating: "a", count: ActivityJSON.maxPayloadBytes)
        #expect(ActivityJSON.parse("\"\(text)\"") == nil)
    }

    @Test func shallowMergeKeepsPositionsReplacesWholeValuesAndAppendsNewKeys() throws {
        let base = try #require(ActivityJSON.parse(#"{"query":"x","result":{"a":1,"b":2},"status":"in_progress"}"#))
        let update = try #require(ActivityJSON.parse(#"{"status":"complete","result":{"c":3},"url":"u"}"#))
        let merged = base.mergingTopLevel(update)
        #expect(merged.serialized() == #"{"query":"x","result":{"c":3},"status":"complete","url":"u"}"#)
    }

    @Test(arguments: ["null", "false", "0", "\"\""])
    func presentResultReplacesEvenFalsyValues(_ value: String) throws {
        let base = try #require(ActivityJSON.parse(#"{"result":{"a":1}}"#))
        let update = try #require(ActivityJSON.parse(#"{"result":\#(value)}"#))
        #expect(base.mergingTopLevel(update)["result"] == ActivityJSON.parse(value))
    }

    @Test func previews() throws {
        let json = try #require(ActivityJSON.parse(#"{"s":"text","n":4,"b":false,"z":null,"o":{"a":1,"b":2,"c":3},"l":[1,2,3,4,5,6,7,8]}"#))
        #expect(json["s"]?.preview == "text")
        #expect(json["n"]?.preview == "4")
        #expect(json["b"]?.preview == "false")
        #expect(json["z"]?.preview == "null")
        #expect(json["o"]?.preview == "Object(3)")
        #expect(json["l"]?.preview == "Array(8)")
    }

    @Test(arguments: [
        ("null", false), ("{}", false), ("[]", false), ("\"\"", false),
        (#"{"result":null}"#, true), (#"{"ok":false}"#, true), (#"{"count":0}"#, true),
        ("[1]", true), ("\"x\"", true), ("0", true), ("false", true)
    ])
    func retentionQualification(_ source: String, _ qualifies: Bool) throws {
        let json = try #require(ActivityJSON.parse(source))
        #expect(json.qualifiesForRetention == qualifies)
    }

    @Test func rejectsInvalidUTF8InsideStrings() {
        var bytes = Array(#"{"s":"a"#.utf8)
        bytes.append(0xFF)
        bytes.append(contentsOf: Array(#""}"#.utf8))
        #expect(ActivityJSON.parse(Data(bytes)) == nil)
    }

    @Test func copyAsJsonKeepsEveryCallInOrderWithResults() throws {
        let first = try #require(ActivityJSON.parse(#"{"tool_call_id":"1","result":{"n":12345678901234567890}}"#))
        let second = try #require(ActivityJSON.parse(#"{"tool_call_id":"2","status":"error"}"#))
        let exported = ActivityJSON.array([first, second]).serialized(pretty: true)
        let reparsed = try #require(ActivityJSON.parse(exported))
        #expect(reparsed == .array([first, second]))
        #expect(exported.contains("12345678901234567890"))
    }

    @Test func snapshotHidesReservedKeysFromMetadataRows() throws {
        let data = try #require(ActivityJSON.parse(#"{"tool_call_id":"1","tool_name":"search","status":"complete","result":{"a":1},"query":"q","url":"u"}"#))
        let item = ActivityItem(
            id: "item-0", toolCallId: "1", publisher: "agent", runId: "run-0", order: 0,
            text: nil, data: data, lifecycle: .complete, lastSeenAt: Date()
        )
        let snapshot = ActivityItemSnapshot(item: item, now: Date())
        #expect(snapshot.metadata.map(\.key) == ["query", "url"])
        #expect(snapshot.toolName == "search")
        #expect(snapshot.data == data)
    }

    @Test func sortedKeysSerializationIgnoresKeyOrder() throws {
        let first = try #require(ActivityJSON.parse(#"{"a":1,"b":{"y":1,"x":2}}"#))
        let second = try #require(ActivityJSON.parse(#"{"b":{"x":2,"y":1},"a":1}"#))
        #expect(first.serialized(sortedKeys: true) == second.serialized(sortedKeys: true))
    }
}

@Suite
struct ChatActivityPayloadsTests {

    @Test func typingRoundTrip() throws {
        let payload = ChatTypingPayload(sessionId: "9f2c1a0e", active: true, replyTo: "post")
        #expect(String(decoding: payload.encoded(), as: UTF8.self) == #"{"sessionId":"9f2c1a0e","replyTo":"post","active":true}"#)
        #expect(ChatTypingPayload.decode(payload.encoded()) == payload)
    }

    @Test func typingStopHasNoReplyTo() {
        let payload = ChatTypingPayload(sessionId: "s", active: false)
        #expect(String(decoding: payload.encoded(), as: UTF8.self) == #"{"sessionId":"s","active":false}"#)
    }

    @Test func typingDecodeIgnoresUnknownFieldsAndKeepsBlockId() throws {
        let payload = try #require(ChatTypingPayload.decode(Data(#"{"sessionId":"s","active":true,"blockId":"b","future":1}"#.utf8)))
        #expect(payload.blockId == "b")
        #expect(payload.active)
    }

    @Test(arguments: [#"{"active":true}"#, #"{"sessionId":"","active":true}"#, "[]", "nope"])
    func typingDecodeRejectsMissingSession(_ source: String) {
        #expect(ChatTypingPayload.decode(Data(source.utf8)) == nil)
    }

    @Test(arguments: [#"{}"#, #"{"text":""}"#, #"{"text":"   "}"#, #"{"text":null}"#, #"{"text":5}"#])
    func blankOrMissingTextFallsBackToDefault(_ source: String) throws {
        let payload = try #require(ChatStatusPayload.decode(Data(source.utf8)))
        #expect(payload.text == nil)
        #expect(payload.retainedData == nil)
    }

    @Test func statusDecodesReplyToAndToolCall() throws {
        let payload = try #require(ChatStatusPayload.decode(Data(#"{"text":"Reading","reply_to":"msg","data":{"tool_call_id":"call_2","status":"in_progress"}}"#.utf8)))
        #expect(payload.text == "Reading")
        #expect(payload.replyTo == "msg")
        #expect(payload.toolCallId == "call_2")
    }

    @Test func emptyDataObjectIsTextOnly() throws {
        let payload = try #require(ChatStatusPayload.decode(Data(#"{"text":"Searching","data":{}}"#.utf8)))
        #expect(payload.retainedData == nil)
    }

    @Test func topics() {
        #expect(ChatActivityTopic.parse("typing/abc") == .typing(objectId: "abc"))
        #expect(ChatActivityTopic.parse("status/abc") == .status(chatId: "abc"))
        #expect(ChatActivityTopic.parse("presence/abc") == nil)
        #expect(ChatActivityTopic.parse("typing/") == nil)
    }
}
