import Foundation
import UIKit

final class UIAnytypeActivityIndicator: UIView {

    private enum Constants {
        static let animationKey = "rotation"
    }

    // MARK: - Private properties
    
    private let circleLayer = CAShapeLayer()
    private let indicatorLayer = CAShapeLayer()

    // MARK: - Public properties
    
    var circleColor: UIColor = .buttonInactive {
        didSet { updateColors() }
    }

    var indicatorColor: UIColor = .buttonActive {
        didSet { updateColors() }
    }

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 20, height: 20)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        stopAnimation()
        updateLayout()
//        reinstallAnimation()
//        setupAnimationIfNeeded()
    }

    // MARK: - Public
    
    func startAnimation() {
        reinstallAnimation()
    }
//
//    func stopAnimation() {
//        stopAnimation()
//    }
    
    // MARK: - Private
    
    private func setup() {

        layer.addSublayer(circleLayer)
        circleLayer.lineWidth = 2
        circleLayer.fillColor = UIColor.clear.cgColor

        layer.addSublayer(indicatorLayer)
        indicatorLayer.lineWidth = circleLayer.lineWidth
        indicatorLayer.fillColor = UIColor.clear.cgColor
        indicatorLayer.strokeStart = 0
        indicatorLayer.strokeEnd = 0.25

        updateColors()
        updateLayout()
        reinstallAnimation()
    }

    func stopAnimation() {
        indicatorLayer.removeAnimation(forKey: Constants.animationKey)

    }

    private func reinstallAnimation() {

//        guard indicatorLayer.animation(forKey: Constants.animationKey) == nil else { return }
//        indicatorLayer.removeAnimation(forKey: Constants.animationKey)
        
//        indicatorLayer.setNeedsLayout()
//        indicatorLayer.layoutIfNeeded()
  
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
        
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        animation.valueFunction = CAValueFunction(name: CAValueFunctionName.rotateZ)
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false

        indicatorLayer.add(animation, forKey: Constants.animationKey)

//        CATransaction.commit()
    }

    private func updateColors() {
        circleLayer.strokeColor = circleColor.cgColor
        indicatorLayer.strokeColor = indicatorColor.cgColor
    }

    private func updateLayout() {
        let squareSide = min(bounds.width, bounds.height)
        let squareBounds = CGRect(
            x: (bounds.width - squareSide) * 0.5,
            y: (bounds.height - squareSide) * 0.5,
            width: squareSide,
            height: squareSide
        )

        let inset = circleLayer.lineWidth * 0.5
        let insets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        let pathRect = squareBounds.inset(by: insets)
        circleLayer.path = UIBezierPath(ovalIn: pathRect).cgPath
        circleLayer.frame = bounds

        indicatorLayer.path = circleLayer.path
        indicatorLayer.frame = circleLayer.frame
//        indicatorLayer.bounds = circleLayer.bounds
//        indicatorLayer.position = circleLayer.position
    }
}
