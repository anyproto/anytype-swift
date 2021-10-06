import CoreGraphics

enum HomeBottomSheetViewState: Equatable {
    case open
    case closed
    case drag(offset: CGFloat)
    case finishDrag(offset: CGFloat)
}
