import CoreGraphics

extension CGSize: Comparable {
    
    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        lhs.width < rhs.width && lhs.height < rhs.height
    }
    
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
