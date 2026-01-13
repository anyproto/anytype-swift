import UIKit

final class UIEditorBarButtonItem: UIView, CustomizableHitTestAreaView {
    // CustomizableHitTestAreaView
    var minHitTestArea: CGSize = Constants.minimumHitArea

    private let button = UIButton(type: .custom)

    init(imageAsset: ImageAsset, action: @escaping () -> Void) {
        super.init(frame: .zero)
        setup(imageAsset: imageAsset, action: action)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return containsCustomHitTestArea(point) ? button : nil
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension UIEditorBarButtonItem {

    func setup(imageAsset: ImageAsset, action: @escaping () -> Void) {
        setupButton(imageAsset: imageAsset, action: action)
        setupLayout()
    }

    func setupButton(imageAsset: ImageAsset, action: @escaping () -> Void) {
        button.setImage(UIImage(asset: imageAsset), for: .normal)
        button.tintColor = .Control.secondary
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

        addSubview(button) {
            $0.pinToSuperview()
        }
    }

    func enableAnimation(_ inAnimator: ViewAnimator<UIView>, _ outAnimator: ViewAnimator<UIView>) {
        let recognizer = TouchGestureRecognizer { [weak self] recognizer in
            guard let self else { return }
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

private extension UIEditorBarButtonItem {

    enum Constants {
        static let animationDuration: TimeInterval = 0.1
        static let pressedScale: CGFloat = 0.8

        static let minimumHitArea = CGSize(width: 44, height: 44)
    }
}
