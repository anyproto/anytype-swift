enum EditorSelectionIncomingCellEvent: Equatable {
    static func == (lhs: EditorSelectionIncomingCellEvent, rhs: EditorSelectionIncomingCellEvent) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown): return true
        case let (.payload(left), .payload(right)): return left.selectionEnabled == right.selectionEnabled && left.isSelected == right.isSelected
        default: return false
        }
    }
    
    struct Payload {
        var selectionEnabled: Bool
        var isSelected: Bool
    }
    case unknown
    case payload(Payload)
}
