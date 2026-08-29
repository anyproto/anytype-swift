import Services

// What the object's header will look like once details load. Flows that already
// hold the details (search results, links) pass it along so the placeholder
// header matches the real height instead of visibly collapsing when data arrives.
enum ObjectHeaderExpectedLayout: Hashable, Codable {
    case iconAndCover
    case iconOnly
    case coverOnly
    case empty

    init(details: ObjectDetails) {
        if details.resolvedLayoutValue.isNote {
            self = .empty
            return
        }
        let hasIcon = details.resolvedLayoutValue.haveIcon && details.objectIcon != nil
        let hasCover = details.documentCover != nil
        switch (hasIcon, hasCover) {
        case (true, true):
            self = .iconAndCover
        case (true, false):
            self = .iconOnly
        case (false, true):
            self = .coverOnly
        case (false, false):
            self = .empty
        }
    }
}
