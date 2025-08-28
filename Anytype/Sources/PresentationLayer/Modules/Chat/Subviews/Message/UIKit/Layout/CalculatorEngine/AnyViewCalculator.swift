import Foundation

struct AnyViewCalculator: ViewCalculator {
    
    let sizeProvider: (_ size: CGSize) -> CGSize
    
    func sizeThatFits(_ size: CGSize) -> CGSize {
        sizeProvider(size)
    }
    
    func setFrame(_ frame: CGRect) {}
}

extension AnyViewCalculator {
    init(size: CGSize) {
        self.sizeProvider = { _ in size }
    }
}

