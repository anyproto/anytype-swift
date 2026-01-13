import UIKit

@available(iOS, deprecated: 26.0)
final class GlassContainerViewIOS26: UIView {

    private var containerEffectView: UIVisualEffectView?
    private let fallbackContentView = UIView()

    init(spacing: CGFloat = 12) {
        super.init(frame: .zero)
        setupGlassContainer(spacing: spacing)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var glassContentView: UIView {
        containerEffectView?.contentView ?? fallbackContentView
    }

    private func setupGlassContainer(spacing: CGFloat) {
        if #available(iOS 26.0, *) {
            let containerEffect = UIGlassContainerEffect()
            containerEffect.spacing = spacing
            let effectView = UIVisualEffectView(effect: containerEffect)
            addSubview(effectView) {
                $0.pinToSuperview()
            }
            containerEffectView = effectView
        } else {
            backgroundColor = .Background.navigationPanel
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            addSubview(blurView) {
                $0.pinToSuperview()
            }
            blurView.contentView.addSubview(fallbackContentView) {
                $0.pinToSuperview()
            }
        }
    }
}

@available(iOS, deprecated: 26.0)
final class GlassEffectViewIOS26: UIView {

    private var glassEffectView: UIVisualEffectView?
    private let contentContainer = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGlassEffect()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var glassContentView: UIView {
        glassEffectView?.contentView ?? contentContainer
    }

    private func setupGlassEffect() {
        if #available(iOS 26.0, *) {
            let glassEffect = UIGlassEffect()
            glassEffect.isInteractive = true
            let effectView = UIVisualEffectView(effect: glassEffect)
            addSubview(effectView) {
                $0.pinToSuperview()
            }
            glassEffectView = effectView
        } else {
            backgroundColor = .Background.navigationPanel
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            addSubview(blurView) {
                $0.pinToSuperview()
            }
            blurView.contentView.addSubview(contentContainer) {
                $0.pinToSuperview()
            }
        }
    }

    func applyCircleShape(diameter: CGFloat) {
        if #available(iOS 26.0, *) {
            glassEffectView?.cornerConfiguration = .capsule()
        } else {
            layer.cornerRadius = diameter / 2
            clipsToBounds = true
        }
    }

    func applyCapsuleShape(height: CGFloat) {
        if #available(iOS 26.0, *) {
            glassEffectView?.cornerConfiguration = .capsule()
        } else {
            layer.cornerRadius = height / 2
            clipsToBounds = true
        }
    }
}

@available(iOS, deprecated: 26.0)
extension UIButton.Configuration {
    static func glassIOS26() -> UIButton.Configuration {
        if #available(iOS 26.0, *) {
            return .glass()
        } else {
            var config = UIButton.Configuration.plain()
            config.background.backgroundColor = .Background.navigationPanel
            return config
        }
    }
}
