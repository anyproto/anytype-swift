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

        case title(TitleModel)
        case modeTitle(String)
    }

    
    func configure(model: Mode) {
        switch model {
        case let .title(titleModel):
            titleLabel.setText(titleModel.title ?? "", style: .uxCalloutRegular)
            iconImageView.isHidden = titleModel.icon.isNil
            iconImageView.icon = titleModel.icon
        case let .modeTitle(text):
            titleLabel.setText(text, style: .uxTitle1Semibold)
            iconImageView.isHidden = true
        }
    }

    func setIsReadonly(_ isReadonly: EditorEditingState.ReadonlyState?) {
        lockImageView.isHidden = isReadonly.isNil
        lockImageView.image = isReadonly.flatMap { UIImage(asset: $0.barIcon) }
    }
    
    /// Parents alpha sets automatically by system when it attaches to NavigationBar. 
    func setAlphaForSubviews(_ alpha: CGFloat) {
        titleLabel.alpha = alpha
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
        lockImageView.tintColor = .Button.active
        
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

        iconImageView.layoutUsing.anchors {
            $0.size(CGSize(width: 18, height: 18))
        }

        lockImageView.layoutUsing.anchors {
            $0.size(CGSize(width: 18, height: 18))
        }
    }
}

private extension EditorEditingState.ReadonlyState {
    var barIcon: ImageAsset {
        switch self {
        case .locked:
            return .X18.lock
        case .archived:
            return .X18.delete
        }
    }
}
