import ProtobufMessages

/// TODO:
/// Add concrete `Success` types for protocols.
/// Most of the time we need `ServiceSuccess` type.
/// In other cases we could provide concrete type.
/// For that we could add `Success` type for appropriate namespace in this nested enum `ServiceLayerModule`.
///

struct ServiceSuccess {
    var contextID: String
    var messages: [Anytype_Event.Message]
    init(_ value: Anytype_ResponseEvent) {
        self.contextID = value.contextID
        self.messages = value.messages
    }
}
