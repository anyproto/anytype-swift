import Foundation
import UIKit

enum EditorNavigationBarTitleMode {
    case edit
    case locked
    case archived
}

final class EditorNavigationBarTitleView: UIView {
    
    private let stackView = UIStackView()
    
    private let iconImageView = IconViewUIKit()
    private let titleLabel = AnytypeLabel(style: .uxCalloutRegular)
    private let lockImageView = UIImageView()
    private let arrowImageView = UIImageView()
    
    private var mode: Mode?
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditorNavigationBarTitleView: ConfigurableView {

    enum Mode {
        struct TitleModel {
            let icon: Icon?
            let title: String?
        }
        
        struct TemplatesModel {
            let count: Int
            let onTap: () -> Void
        }

        case title(TitleModel)
        case modeTitle(String)
        case templates(TemplatesModel)
    }

    
    func configure(model: Mode) {
        switch model {
        case let .title(titleModel):
            titleLabel.setText(titleModel.title ?? "", style: .uxCalloutRegular)
            titleLabel.isUserInteractionEnabled = false
            iconImageView.isHidden = titleModel.icon.isNil
            iconImageView.icon = titleModel.icon
            arrowImageView.isHidden = true
        case let .modeTitle(text):
            titleLabel.setText(text, style: .uxTitle1Semibold)
            titleLabel.isUserInteractionEnabled = false
            iconImageView.isHidden = true
            arrowImageView.isHidden = true
        case let .templates(model):
            titleLabel.setText(Loc.TemplateSelection.Available.title(model.count), style: .caption1Medium)
            titleLabel.isUserInteractionEnabled = true
            titleLabel.addTapGesture { _ in model.onTap() }
            arrowImageView.isHidden = false
            arrowImageView.addTapGesture { _ in model.onTap() }
            iconImageView.isHidden = true
        }
        mode = model
    }

    func setIsReadonly(_ isReadonly: BlocksReadonlyReason?) {
        lockImageView.isHidden = isReadonly.isNil
        lockImageView.image = isReadonly.flatMap { UIImage(asset: $0.barIcon) }
    }
    
    /// Parents alpha sets automatically by system when it attaches to NavigationBar. 
    func setAlphaForSubviews(_ alpha: CGFloat) {
        if case .templates = mode {
            titleLabel.alpha = 1
        } else {
            titleLabel.alpha = alpha
        }
        iconImageView.alpha = alpha
        lockImageView.alpha = alpha
    }
    
}

private extension EditorNavigationBarTitleView {
    
    func setupView() {
        titleLabel.textColor = .Text.primary
        titleLabel.numberOfLines = 1
        
        iconImageView.contentMode = .scaleAspectFit
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        lockImageView.contentMode = .center
        lockImageView.tintColor = .Control.secondary
        
        arrowImageView.contentMode = .center
        arrowImageView.tintColor = .Text.primary
        arrowImageView.image = UIImage(asset: .X18.listArrow)
        arrowImageView.isHidden = true
        
        setupLayout()        
    }
    
    func setupLayout() {
        addSubview(stackView) {
            $0.width.lessThanOrEqual(to: 300)
            $0.pinToSuperview()
        }

        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(lockImageView)
        stackView.addArrangedSubview(arrowImageView)

        iconImageView.layoutUsing.anchors {
            $0.size(CGSize(width: 18, height: 18))
        }

        lockImageView.layoutUsing.anchors {
            $0.size(CGSize(width: 18, height: 18))
        }
        
        arrowImageView.layoutUsing.anchors {
            $0.size(CGSize(width: 18, height: 18))
        }
    }
}

private extension BlocksReadonlyReason {
    var barIcon: ImageAsset {
        switch self {
        case .locked, .restrictions, .spaceIsReadonly:
            return .X18.lock
        case .archived:
            return .X18.delete
        }
    }
}
