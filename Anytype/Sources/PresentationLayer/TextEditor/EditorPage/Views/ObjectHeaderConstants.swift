import CoreGraphics

enum ObjectHeaderConstants {
    static let minimizedHeaderHeight: CGFloat = 48
    static let emptyViewHeight: CGFloat = 124
    static let emptyViewHeightCompact: CGFloat = 32
    // The editor's collection view ignores safe area insets, so this blank header is the
    // only thing holding the title clear of whatever floats above it. In a sheet that is
    // the drag indicator (17) plus the capture header (60), not a navigation bar.
    static let emptyViewHeightSheet: CGFloat = 88
    
    static let coverHeight: CGFloat = 228
    static let coverBottomInset: CGFloat = 32
    static let coverFullHeight = coverHeight + coverBottomInset
    
    static let iconHorizontalInset: CGFloat = 20 - ObjectHeaderIconView.Constants.borderWidth
    static let iconBottomInset: CGFloat = 16 - ObjectHeaderIconView.Constants.borderWidth
}
