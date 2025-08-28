import Foundation

struct HorizontalSpacerCalculator: ViewCalculator {
    
    func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 0)
    }
    
    func setFrame(_ frame: CGRect) {}
}
