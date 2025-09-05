import Foundation
import UIKit

final class MessageSwipeView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: - Gesture Config
    
    private let minReplyWidth: CGFloat = 50
    private let replyImageWidth: CGFloat = 32
    
    private let gesture = UIPanGestureRecognizer()
    private let replyImage = {
        let view = UIImageView()
        view.image = UIImage(asset: .X32.reply)
        view.tintColor = .Control.primary
        return view
    }()
    private var offsetX: CGFloat = 0
    private var hasTriggeredFeedback = false
    
    // MARK: - Piblic properties
    
    var enableGesture: Bool {
        get { gesture.isEnabled }
        set { gesture.isEnabled = newValue }
    }
    
    var onReply: (() -> Void)?
    
    let contentView = UIView()
    
    // MARK: - Piblic
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        gesture.addTarget(self, action: #selector(handlePan))
        gesture.delegate = self
        addGestureRecognizer(gesture)
        addSubview(contentView)
        addSubview(replyImage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds.offsetBy(dx: offsetX, dy: 0)
        let imageFrame = CGRect(
            x: bounds.maxX - replyImageWidth,
            y: bounds.minY + (bounds.height - replyImageWidth) * 0.5,
            width: replyImageWidth,
            height: replyImageWidth
        )
        let progress = (-offsetX / minReplyWidth).clamped(to: 0...1)
        replyImage.frame = imageFrame.offsetBy(dx: -100 * progress, dy: 0)
        replyImage.layer.opacity = Float(progress)
        // TODO: Fix singular matrix.
        let transform = CGAffineTransform(scaleX: progress, y: progress)
        replyImage.layer.setAffineTransform(transform)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer, let view = pan.view else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        
        let velocity = pan.velocity(in: view)
        
        let isHorizontal = abs(velocity.x) > abs(velocity.y)
        
        // deviation from the horizontal axis by no more than 25 degrees
        let angle = atan2(velocity.y, velocity.x) * 180 / .pi
        let withinDeviationAngle = (angle > 155 || angle < -155)
        
        return isHorizontal && withinDeviationAngle
    }
    
    // MARK: - Private
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        switch gesture.state {
        case .changed:
            guard translation.x < 0 else { return }

            offsetX = translation.x

            if !hasTriggeredFeedback && -offsetX >= minReplyWidth {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                hasTriggeredFeedback = true
            }
            setNeedsLayout()
        case .ended:
            if abs(translation.x) > minReplyWidth {
                onReply?()
            }
            offsetX = 0
            setNeedsLayout()
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
            hasTriggeredFeedback = false
        default:
            break
        }
    }
    
}
