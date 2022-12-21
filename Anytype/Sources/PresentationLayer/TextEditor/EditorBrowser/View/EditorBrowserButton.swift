import UIKit

final class EditorBrowserButton: UIView, CustomizableHitTestAreaView {
    var isEnabled: Bool {
        didSet {
            handleEnableUpdate()
        }
    }
    
    // CustomizableHitTestAreaView
    var minHitTestArea: CGSize = Constants.minimumHitArea

    private let button = UIButton(type: .custom)
    
    init(imageAsset: ImageAsset, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.isEnabled = isEnabled
        super.init(frame: .zero)
        
        setupView(imageAsset: imageAsset, action: action)
    }

    func updateMenu(_ menu: UIMenu) {
        button.menu = menu
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return containsCustomHitTestArea(point) ? self.button : nil
    }
    
    private func setupView(imageAsset: ImageAsset, action: @escaping () -> Void) {
        setupButton(imageAsset: imageAsset, action: action)
        setupLayout()
        handleEnableUpdate()
        
        enableAnimation(
            .scale(toScale: Constants.pressedScale, duration: Constants.animationDuration),
            .undoScale(scale: Constants.pressedScale, duration: Constants.animationDuration)
        )
    }
    
    private func setupButton(imageAsset: ImageAsset, action: @escaping () -> Void) {
        let image = UIImage(asset: imageAsset)
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.adjustsImageWhenHighlighted = false
        
        button.addAction(
            UIAction(
                handler: {_ in
                    action()
                }
            ),
            for: .touchUpInside
        )
    }
    
    private func setupLayout() {
        layoutUsing.anchors {
            $0.size(CGSize(width: 24, height: 24))
        }
        
        addSubview(button) {
            $0.pinToSuperview()
        }
    }

    private func enableAnimation(_ inAnimator: ViewAnimator<UIView>, _ outAnimator: ViewAnimator<UIView>) {
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
    
    private func handleEnableUpdate() {
        button.isEnabled = isEnabled
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self = self else { return }
            self.button.tintColor = self.isEnabled ? .TextNew.secondary : .TextNew.tertiary
        }
    }
    
    // MARK: - Private
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EditorBrowserButton {
    
    enum Constants {
        static let animationDuration: TimeInterval = 0.1
        static let pressedScale: CGFloat = 0.8
        
        static let minimumHitArea = CGSize(width: 66, height: 66)
    }
    
}
