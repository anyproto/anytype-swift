import Foundation
import AnytypeCore

enum ChatActivityTopic {

    static func typing(objectId: String) -> String {
        "typing/\(objectId)"
    }

    static func status(chatId: String) -> String {
        "status/\(chatId)"
    }

    enum Kind: Equatable {
        case typing(objectId: String)
        case status(chatId: String)
    }

    static func parse(_ topic: String) -> Kind? {
        let parts = topic.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[1].isEmpty else { return nil }
        let id = String(parts[1])
        switch parts[0] {
        case "typing":
            return .typing(objectId: id)
        case "status":
            return .status(chatId: id)
        default:
            return nil
        }
    }
}

/// `typing/<objectId>` payload. Full state, refreshed by the sender and expired by the receiver.
struct ChatTypingPayload: Equatable, Sendable {
    let sessionId: String
    let active: Bool
    /// Discussions only: the post a reply composer answers. Absent for the main composer.
    let replyTo: String?
    /// Editor presence. Composers never send it; receivers ignore such entries on chat topics.
    let blockId: String?

    init(sessionId: String, active: Bool, replyTo: String? = nil, blockId: String? = nil) {
        self.sessionId = sessionId
        self.active = active
        self.replyTo = replyTo
        self.blockId = blockId
    }

    static func decode(_ data: Data) -> ChatTypingPayload? {
        guard let json = ActivityJSON.parse(data), json.fields != nil,
              let sessionId = json["sessionId"]?.nonEmptyString else { return nil }
        return ChatTypingPayload(
            sessionId: sessionId,
            active: json["active"]?.boolValue ?? false,
            replyTo: json["replyTo"]?.nonEmptyString,
            blockId: json["blockId"]?.nonEmptyString
        )
    }

    func encoded() -> Data {
        var fields = [ActivityJSONField(key: "sessionId", value: .string(sessionId))]
        if let replyTo {
            fields.append(ActivityJSONField(key: "replyTo", value: .string(replyTo)))
        }
        fields.append(ActivityJSONField(key: "active", value: .bool(active)))
        return Data(ActivityJSON.object(fields).serialized().utf8)
    }
}

/// `status/<chatId>` payload published by agents through API v2.
struct ChatStatusPayload: Equatable, Sendable {
    /// Plain display text; nil means the localized default ("Typing").
    let text: String?
    /// Discussions only: the message the activity answers.
    let replyTo: String?
    let data: ActivityJSON?

    init(text: String?, replyTo: String? = nil, data: ActivityJSON? = nil) {
        self.text = text
        self.replyTo = replyTo
        self.data = data
    }

    static func decode(_ data: Data) -> ChatStatusPayload? {
        guard let json = ActivityJSON.parse(data), json.fields != nil else { return nil }
        let text = json["text"]?.stringValue.flatMap {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0
        }
        return ChatStatusPayload(text: text, replyTo: json["reply_to"]?.nonEmptyString, data: json["data"])
    }

    /// Data worth keeping as an item; nil makes the event a transient text-only status.
    var retainedData: ActivityJSON? {
        guard let data, data.qualifiesForRetention else { return nil }
        return data
    }

    var toolCallId: String? {
        retainedData?["tool_call_id"]?.nonEmptyString
    }
}
