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
    
    var circleColor: UIColor = .Control.tertiary {
        didSet { updateColors() }
    }

    var indicatorColor: UIColor = .Control.secondary {
        didSet { updateColors() }
    }
    
    var hidesWhenStopped = false

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
        updateLayout()
    }

    // MARK: - Public

    func startAnimation() {
        if hidesWhenStopped {
            isHidden = false
        }
        installAnimation()
    }

    func stopAnimation() {
        if hidesWhenStopped {
            isHidden = true
        }
        deleteAnimation()
    }
    
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
        installAnimation()
    }

    private func deleteAnimation() {
        indicatorLayer.removeAnimation(forKey: Constants.animationKey)
    }

    private func installAnimation() {

        guard indicatorLayer.animation(forKey: Constants.animationKey) == nil else { return }
        
        guard !isHidden else { return }
                
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        animation.valueFunction = CAValueFunction(name: CAValueFunctionName.rotateZ)
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false

        indicatorLayer.add(animation, forKey: Constants.animationKey)
    }

    private func updateColors() {
        circleLayer.strokeColor = circleColor.cgColor
        indicatorLayer.strokeColor = indicatorColor.cgColor
    }

    private func updateLayout() {
        
        // Drop side effects from outside animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
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
        
        CATransaction.commit()
    }
}
