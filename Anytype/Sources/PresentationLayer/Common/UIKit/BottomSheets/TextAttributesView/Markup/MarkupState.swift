
enum MarkupState: CaseIterable {
    case disabled
    case applied
    case notApplied
    
    mutating func toggleAppliedState() {
        guard self != .disabled else { return }
        if self == .applied {
            self = .notApplied
        } else {
            self = .applied
        }
    }
}
