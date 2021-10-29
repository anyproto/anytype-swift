enum ObjectHeaderFilledState: Hashable {
    case iconOnly(ObjectHeaderIcon)
    case coverOnly(ObjectHeaderCover)
    case iconAndCover(icon: ObjectHeaderIcon, cover: ObjectHeaderCover)
    
    var isWithCover: Bool {
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
