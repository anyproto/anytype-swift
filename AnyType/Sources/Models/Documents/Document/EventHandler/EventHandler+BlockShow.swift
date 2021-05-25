import ProtobufMessages

extension EventHandler {
    func handleBlockShow(events: EventListening.PackOfEvents) -> [BlocksModelsParser.PageEvent] {
        events.events.compactMap(\.value).compactMap(self.handleBlockShow(event:))
    }
    
    private func handleBlockShow(event: Anytype_Event.Message.OneOf_Value) -> BlocksModelsParser.PageEvent {
        switch event {
        case let .blockShow(value): return self.parser.parse(blocks: value.blocks, details: value.details, smartblockType: value.type)
        default: return .empty()
        }
    }
}
