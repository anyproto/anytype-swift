import UIKit

extension EditorBarButtonItem {
    enum Style {
        case settings(image: UIImage, action: () -> Void)
        case syncStatus(image: UIImage, title: String, description: String)
    }
}

final class EditorBarButtonItem: UIView, CustomizableHitTestAreaView {
    // CustomizableHitTestAreaView
    var minHitTestArea: CGSize = Constants.minimumHitArea
    
    private let backgroundView = UIView()
    private let button = UIButton(type: .custom)
    
    private var style: Style
    private var backgroundAlpha: CGFloat = 0.0
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return containsCustomHitTestArea(point) ? button : nil
    }
    
    func changeBackgroundAlpha(_ alpha: CGFloat) {
        if backgroundAlpha != alpha {
            handleAlphaUpdate(alpha)
        }
    }
    
    func changeStyle(style: Style) {
        self.style = style
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.setupButton()
        }, completion: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EditorBarButtonItem {
    
    func setup() {
        setupBackgroundView()
        setupButton()
        setupLayout()
        
        handleAlphaUpdate(backgroundAlpha)
    }
    
    func setupBackgroundView() {
        backgroundView.backgroundColor = .black.withAlphaComponent(0.35)
        backgroundView.layer.cornerRadius = 7
    }
    
    func setupButton() {
        switch style {
        case let .settings(image: image, action: action):
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
        case let .syncStatus(image: image, title: title, description: description):
            button.setImage(image, for: .normal)
            button.setTitle(title, for: .normal)
            button.centerTextAndImage(spacing: 6)
            button.showsMenuAsPrimaryAction = true
            button.menu = UIMenu(title: "", children: [ UIAction(title: description) { _ in } ] )
        }
    }
    
    func setupLayout() {
        layoutUsing.anchors {
            switch style {
            case .syncStatus:
                $0.height.equal(to: 28)
                $0.centerY.equal(to: centerYAnchor)
            case .settings:
                $0.size(CGSize(width: 28, height: 28))
            }
        }
        
        addSubview(backgroundView) {
            $0.pinToSuperview()
        }
        
        addSubview(button) {
            switch style {
            case .syncStatus:
                $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 9, bottom: 0, right: -10))
            case .settings:
                $0.pinToSuperview()
            }
        }
    }
    
    func handleAlphaUpdate(_ alpha: CGFloat) {
        backgroundAlpha = alpha
        backgroundView.alpha = alpha
        button.tintColor = alpha.isLess(than: 0.5) ? UIColor.textSecondary : UIColor.backgroundPrimary
        button.titleLabel?.font = AnytypeFont.caption1Regular.uiKitFont
        button.setTitleColor(alpha.isLess(than: 0.5) ? UIColor.textSecondary : UIColor.backgroundPrimary, for: .normal)
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

extension UIButton {

    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        let isRTL = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        if isRTL {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: -insetAmount)
        } else {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
        }
    }
}
