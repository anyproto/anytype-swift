import Foundation

protocol ViewCalculator {
    func sizeThatFits(_ targetSize: CGSize) -> CGSize
    func setFrame(_ frame: CGRect)
    func layoutPriority() -> Float
}

extension ViewCalculator {
    func layoutPriority() -> Float { .zero }
}

struct ViewCalculatorLayoutPriorityBox<T: ViewCalculator>: ViewCalculator {
    let priority: Float
    let box: T
    
    func sizeThatFits(_ targetSize: CGSize) -> CGSize {
        box.sizeThatFits(targetSize)
    }
    
    func setFrame(_ frame: CGRect) {
        box.setFrame(frame)
    }
    
    func layoutPriority() -> Float {
        priority
    }
}

extension ViewCalculator {
    func layoutPriority(_ priority: Float) -> ViewCalculatorLayoutPriorityBox<Self> {
        ViewCalculatorLayoutPriorityBox(priority: priority, box: self)
    }
}

extension ViewCalculator {
    func calculate(_ targetSize: CGSize) {
        let size = sizeThatFits(targetSize)
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
