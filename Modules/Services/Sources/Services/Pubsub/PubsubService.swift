import Foundation
import ProtobufMessages

/// Ephemeral, at-most-once, space-scoped publish/subscribe. Messages arrive as
/// `Event.Pubsub.Message`; nothing is stored or replayed. Failures are never fatal: callers drop
/// the signal and let the next refresh repair state.
public protocol PubsubServiceProtocol: AnyObject, Sendable {
    /// Replaces the topic set of `subId` when it already exists.
    func subscribe(spaceId: String, topics: [String], subId: String) async throws
    func unsubscribe(subId: String) async throws
    /// Concrete topic only. Fire and forget: never queue or retry.
    func publish(spaceId: String, topic: String, payload: Data) async throws
}

final class PubsubService: PubsubServiceProtocol {

    func subscribe(spaceId: String, topics: [String], subId: String) async throws {
        try await ClientCommands.pubsubSubscribe(.with {
            $0.spaceID = spaceId
            $0.topics = topics
            $0.subID = subId
        }).invoke(ignoreLogErrors: .badInput, .unknownError)
    }

    func unsubscribe(subId: String) async throws {
        try await ClientCommands.pubsubUnsubscribe(.with {
            $0.subID = subId
        }).invoke(ignoreLogErrors: .badInput, .unknownError)
    }

    func publish(spaceId: String, topic: String, payload: Data) async throws {
        try await ClientCommands.pubsubPublish(.with {
            $0.spaceID = spaceId
            $0.topic = topic
            $0.payload = payload
        }).invoke(ignoreLogErrors: .badInput, .unknownError)
    }
}
