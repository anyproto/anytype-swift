import Foundation

enum ObjectHeaderEmptyUsecase: Codable {
    case full
    case embedded
    case sheet

    // Owned here so every surface that draws the empty header agrees on its height
    var height: CGFloat {
        switch self {
        case .full:
            ObjectHeaderConstants.emptyViewHeight
        case .embedded:
            ObjectHeaderConstants.emptyViewHeightCompact
        case .sheet:
            ObjectHeaderConstants.emptyViewHeightSheet
        }
    }
}

// Blank clearance above the title, not a control: it used to open the cover picker,
// which reads as a misfire when the tap lands on nothing. Covers are added from the
// object settings menu.
struct ObjectHeaderEmptyData: Hashable {
    let presentationStyle: ObjectHeaderEmptyUsecase
}
