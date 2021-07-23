import ProtobufMessages

/// It seems that Middleware can't provide good model.
/// So, we need to convert this models by ourselves.
///
struct EventDetailsAndSetDetailsConverter {
    static func convert(event: Anytype_Event.Object.Details.Set) -> [Anytype_Rpc.Block.Set.Details.Detail] {
        event.details.fields.map(Anytype_Rpc.Block.Set.Details.Detail.init(key:value:))
    }
}
