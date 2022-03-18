import UIKit

final class EditorBarButtonItem: UIView, CustomizableHitTestAreaView {
    // CustomizableHitTestAreaView
    var minHitTestArea: CGSize = Constants.minimumHitArea
    
    private let backgroundView = UIView()
    private let button = UIButton(type: .custom)
    
    private var state = EditorBarItemState.initial
    
    init(image: UIImage, action: @escaping () -> Void) {
        super.init(frame: .zero)
        setup(image: image, action: action)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return containsCustomHitTestArea(point) ? button : nil
    }
    
    func changeState(_ state: EditorBarItemState) {
        if self.state != state {
            self.state = state
            updateState()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EditorBarButtonItem {
    
    func setup(image: UIImage, action: @escaping () -> Void) {
        setupBackgroundView()
        setupButton(image: image, action: action)
        setupLayout()
        
        updateState()
    }
    
    func setupBackgroundView() {
        backgroundView.backgroundColor = .black.withAlphaComponent(0.35)
        backgroundView.layer.cornerRadius = 7
    }
    
    func setupButton(image: UIImage, action: @escaping () -> Void) {
        button.adjustsImageWhenHighlighted = false
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addAction(
            UIAction(handler: { _ in action() } ),
            for: .touchUpInside
        )
        enableAnimation(
            .scale(toScale: Constants.pressedScale, duration: Constants.animationDuration),
            .undoScale(scale: Constants.pressedScale, duration: Constants.animationDuration)
        )
    }
    
    func setupLayout() {
        layoutUsing.anchors {
            $0.size(CGSize(width: 28, height: 28))
        }
        
        addSubview(backgroundView) {
            $0.pinToSuperview()
        }
        
        addSubview(button) {
            $0.pinToSuperview()
        }
    }
    
    func updateState() {
        backgroundView.alpha = state.backgroundAlpha
        button.tintColor = state.buttonTintColor
    }
    
    func enableAnimation(_ inAnimator: ViewAnimator<UIView>, _ outAnimator: ViewAnimator<UIView>) {
        let recognizer = TouchGestureRecognizer { [weak self] recognizer in
            guard
                let self = self
            else {
                return
            }
            switch recognizer.state {
            case .began:
                inAnimator.animate(self.button)
            case .ended, .cancelled, .failed:
                outAnimator.animate(self.button)
            default:
                return
            }
        }
        recognizer.cancelsTouchesInView = false
        button.addGestureRecognizer(recognizer)
    }
    
}

private extension EditorBarButtonItem {
    
    enum Constants {
        static let animationDuration: TimeInterval = 0.1
        static let pressedScale: CGFloat = 0.8
        
        static let minimumHitArea = CGSize(width: 44, height: 44)
    }
    
}
