import CoreGraphics

enum ObjectHeaderConstants {
    static let minimizedHeaderHeight: CGFloat = 48
    static let emptyViewHeight: CGFloat = 124
    
    static let coverHeight: CGFloat = 228
    static let coverBottomInset: CGFloat = 32
    static let coverFullHeight = coverHeight + coverBottomInset
    
    static let iconHorizontalInset: CGFloat = 20 - ObjectHeaderIconView.Constants.borderWidth
    static let iconBottomInset: CGFloat = 16 - ObjectHeaderIconView.Constants.borderWidth
}
