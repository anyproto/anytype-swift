enum EditorSelectionIncomingEvent {
    enum CountEvent {
        static var `default`: Self = .isEmpty
        case isEmpty
        case nonEmpty(UInt, turnIntoStyles: [BlockToolbar.BlocksTypes])
        static func from(_ value: Int, turnIntoStyles: [BlockToolbar.BlocksTypes]) -> Self {
            value <= 0 ? .isEmpty : nonEmpty(.init(value), turnIntoStyles: turnIntoStyles)
        }
    }
    case selectionDisabled
    case selectionEnabled(CountEvent)
    static var selectionEnabled: Self = .selectionEnabled(.default)
}
