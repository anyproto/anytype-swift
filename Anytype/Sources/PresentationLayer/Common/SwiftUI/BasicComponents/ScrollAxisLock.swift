import SwiftUI
import UIKit.UIGestureRecognizerSubclass

extension View {
    /// Locks the enclosing scroll view's pan gesture to a single axis.
    ///
    /// Apply to the scroll view's *content*, not to the `ScrollView` itself.
    ///
    /// A `UIScrollView` grabs any touch that lands on it while it is still decelerating, at a zero
    /// movement threshold and whatever the direction of the drag that follows — that is how you
    /// catch and re-flick moving content. With nested scroll views (kanban columns inside the
    /// horizontally scrolling board) it also means a still-settling column swallows horizontal
    /// swipes meant for the board. The lock makes the pan wait until the drag has a direction and
    /// begin only for drags along `axis`, so cross-axis drags always reach the other scroll view.
    func scrollAxisLock(_ axis: Axis) -> some View {
        background(ScrollAxisLockView(axis: axis))
    }
}

private struct ScrollAxisLockView: UIViewRepresentable {
    let axis: Axis

    func makeUIView(context: Context) -> UIView {
        ScrollAxisLockUIView(axis: axis)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

private final class ScrollAxisLockUIView: UIView {
    private let gate: CrossAxisDragGate

    // SwiftUI.Axis, not the UIView.Axis that wins name lookup inside a UIView subclass.
    init(axis: SwiftUI.Axis) {
        gate = CrossAxisDragGate(scrollAxis: axis)
        super.init(frame: .zero)
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard window != nil, let scrollView = enclosingScrollView, gate.view !== scrollView else { return }

        scrollView.addGestureRecognizer(gate)
        scrollView.panGestureRecognizer.require(toFail: gate)
    }

    private var enclosingScrollView: UIScrollView? {
        var ancestor: UIView? = superview
        while let current = ancestor {
            if let scrollView = current as? UIScrollView { return scrollView }
            ancestor = current.superview
        }
        return nil
    }
}

/// Recognizes cross-axis drags and nothing else. While it is undecided the scroll view's pan is
/// held back by `require(toFail:)`; once it recognizes, that pan is out for the whole touch. It
/// never prevents other recognizers, so the drag still reaches the surrounding scroll view.
private final class CrossAxisDragGate: UIGestureRecognizer {
    private let scrollAxis: Axis
    private var startLocation = CGPoint.zero

    init(scrollAxis: Axis) {
        self.scrollAxis = scrollAxis
        super.init(target: nil, action: nil)
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        guard let touch = touches.first, numberOfTouches == 1, canScrollAlongAxis else {
            state = .failed
            return
        }
        startLocation = touch.location(in: view)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        guard state == .possible, let touch = touches.first else { return }

        let location = touch.location(in: view)
        let horizontal = abs(location.x - startLocation.x)
        let vertical = abs(location.y - startLocation.y)
        let (alongAxis, acrossAxis) = scrollAxis == .horizontal ? (horizontal, vertical) : (vertical, horizontal)

        if alongAxis > acrossAxis, alongAxis > Constants.directionThreshold {
            state = .failed
        } else if acrossAxis > alongAxis, acrossAxis > Constants.directionThreshold {
            state = .began
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = state == .began ? .ended : .failed
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = state == .began ? .cancelled : .failed
    }

    // A gate that can't be the wrong gate: a scroll view with nothing to scroll along its axis
    // needs no arbitration, and neither does one we attached to by mistake.
    private var canScrollAlongAxis: Bool {
        guard let scrollView = view as? UIScrollView else { return false }
        switch scrollAxis {
        case .horizontal:
            return scrollView.contentSize.width > scrollView.bounds.width
        case .vertical:
            return scrollView.contentSize.height > scrollView.bounds.height
        }
    }

    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool { false }

    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool { false }
}

private extension CrossAxisDragGate {
    enum Constants {
        static let directionThreshold: CGFloat = 6
    }
}
