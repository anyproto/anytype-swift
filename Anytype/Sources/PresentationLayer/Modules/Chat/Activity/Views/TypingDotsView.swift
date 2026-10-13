import SwiftUI
import UIKit

/// Three pulsing dots. One `CABasicAnimation` on a replicated layer runs in the render server,
/// so there is no per-frame work on the main thread. Static under Reduce Motion.
struct TypingDotsView: UIViewRepresentable {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeUIView(context: Context) -> TypingDotsUIView {
        TypingDotsUIView()
    }

    func updateUIView(_ view: TypingDotsUIView, context: Context) {
        view.setAnimated(!reduceMotion)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: TypingDotsUIView, context: Context) -> CGSize? {
        TypingDotsUIView.contentSize
    }
}

final class TypingDotsUIView: UIView {

    private enum Constants {
        static let dotSize: CGFloat = 4
        static let spacing: CGFloat = 3
        static let pulseKey = "pulse"
    }

    static let contentSize = CGSize(width: Constants.dotSize * 3 + Constants.spacing * 2, height: Constants.dotSize)

    private let replicator = CAReplicatorLayer()
    private let dot = CALayer()
    private var animated = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false

        dot.frame = CGRect(x: 0, y: 0, width: Constants.dotSize, height: Constants.dotSize)
        dot.cornerRadius = Constants.dotSize / 2
        replicator.instanceCount = 3
        replicator.instanceTransform = CATransform3DMakeTranslation(Constants.dotSize + Constants.spacing, 0, 0)
        replicator.instanceDelay = 0.2
        replicator.addSublayer(dot)
        layer.addSublayer(replicator)

        updateColor()
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: TypingDotsUIView, _) in
            view.updateColor()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        Self.contentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        replicator.frame = CGRect(
            x: (bounds.width - Self.contentSize.width) / 2,
            y: (bounds.height - Self.contentSize.height) / 2,
            width: Self.contentSize.width,
            height: Self.contentSize.height
        )
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateAnimation()
    }

    func setAnimated(_ animated: Bool) {
        guard self.animated != animated else { return }
        self.animated = animated
        updateAnimation()
    }

    private func updateAnimation() {
        dot.removeAnimation(forKey: Constants.pulseKey)
        guard animated, window != nil else {
            dot.opacity = 0.6
            return
        }
        dot.opacity = 1
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = 0.25
        pulse.toValue = 1
        pulse.duration = 0.6
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulse.isRemovedOnCompletion = false
        dot.add(pulse, forKey: Constants.pulseKey)
    }

    private func updateColor() {
        dot.backgroundColor = UIColor.Text.secondary.resolvedColor(with: traitCollection).cgColor
    }
}
