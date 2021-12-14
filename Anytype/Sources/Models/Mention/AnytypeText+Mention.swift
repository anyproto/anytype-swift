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
        case .body:
            return .body
        case .callout:
            return .callout
        default:
            anytypeAssertionFailure("Not supported mention for forn \(self)", domain: .anytypeText)
            return .body
        }
    }
}
