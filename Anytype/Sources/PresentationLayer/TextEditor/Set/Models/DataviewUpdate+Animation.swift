extension DataviewUpdate {
    var shouldAnimate: Bool {
        switch self {
        case .set:
            return false // Visual glitches on colums change
        case .order, .delete:
            return true
        }
    }
}
