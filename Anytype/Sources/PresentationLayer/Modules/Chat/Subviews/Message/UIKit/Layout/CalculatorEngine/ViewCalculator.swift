import Foundation

protocol ViewCalculator {
    func sizeThatFits(_ size: CGSize) -> CGSize
    func setFrame(_ frame: CGRect)
}

extension ViewCalculator {
    func calculate() {
        setFrame(CGRect(origin: .zero, size: size))
    }
}

struct AnyViewCalculator: ViewCalculator {
    
    let sizeProvider: (_ size: CGSize) -> CGSize
    let frameWriter: (_ rect: CGRect) -> Void
    
    func sizeThatFits(_ size: CGSize) -> CGSize {
        sizeProvider(size)
    }
    
    func setFrame(_ frame: CGRect) {
        frameWriter(frame)
    }
}

extension AnyViewCalculator {
    init(size: CGSize, frameWriter: @escaping (_ rect: CGRect) -> Void) {
        self.sizeProvider = { _ in size }
        self.frameWriter = frameWriter
    }
}
