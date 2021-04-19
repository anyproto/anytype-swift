import BlocksModels

enum EventHandlerFocusConverter {
    typealias EventModel = EventListening.OurEvent.Focus.Payload.Position
    static func asModel(_ value: EventModel) -> BlockFocusPosition {
        switch value {
        case .unknown: return .unknown
        case .beginning: return .beginning
        case .end: return .end
        case let .at(value): return .at(value)
        }
    }
    
    static func asEventModel(_ value: BlockFocusPosition) -> EventModel {
        switch value {
        case .unknown: return .unknown
        case .beginning: return .beginning
        case .end: return .end
        case let .at(value): return .at(value)
        }
    }
}
