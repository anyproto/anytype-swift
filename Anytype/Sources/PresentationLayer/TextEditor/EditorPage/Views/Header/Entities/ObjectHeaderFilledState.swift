enum ObjectHeaderFilledState: Hashable {
    case iconOnly(ObjectHeaderIconOnlyState)
    case coverOnly(ObjectHeaderCover)
    case iconAndCover(icon: ObjectHeaderIcon, cover: ObjectHeaderCover)
    
    var haveCover: Bool {
        switch self {
        case .iconOnly:
            return false
        case .coverOnly:
            return true
        case .iconAndCover:
            return true
        }
    }
}

struct ObjectHeaderIconOnlyState: Hashable {
    
    let icon: ObjectHeaderIcon
    let onCoverTap: () -> Void
}

extension ObjectHeaderIconOnlyState {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(icon)
    }
    
    static func == (lhs: ObjectHeaderIconOnlyState, rhs: ObjectHeaderIconOnlyState) -> Bool {
        lhs.icon == rhs.icon
    }
    
}
