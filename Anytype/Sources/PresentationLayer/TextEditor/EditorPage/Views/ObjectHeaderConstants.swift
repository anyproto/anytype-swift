import CoreGraphics

enum ObjectHeaderConstants {
    static let minimizedHeaderHeight: CGFloat = 48
    static let emptyViewHeight: CGFloat = 92
    
    static let height: CGFloat = 172
    static let coverHeight = height - coverBottomInset
    static let coverBottomInset: CGFloat = 32
    
    static let iconHorizontalInset: CGFloat = 20 - ObjectHeaderIconView.Constants.borderWidth
    static let iconBottomInset: CGFloat = 16 - ObjectHeaderIconView.Constants.borderWidth
}
