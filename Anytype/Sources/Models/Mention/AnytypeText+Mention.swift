import AnytypeCore

extension AnytypeFont {
    var mentionType: ObjectIconImageMentionType {
        switch self {
        case .title:
            return .title
        case .heading:
            return .heading
        case .subheading:
            return .subheading
        case .bodyRegular:
            return .body
        case .calloutRegular:
            return .callout
        default:
            anytypeAssertionFailure("Not supported mention for forn \(self)")
            return .body
        }
    }
}
