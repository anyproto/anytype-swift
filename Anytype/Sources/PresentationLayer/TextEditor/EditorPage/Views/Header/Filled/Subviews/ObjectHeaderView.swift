import Foundation
import UIKit
import Services
import AnytypeCore
import ShimmerSwift

final class ObjectHeaderView: UIView {

    // MARK: - Private variables

    private let iconView = ObjectHeaderIconView()
    private let coverView = ObjectHeaderCoverView()

    private var onIconTap: (() -> Void)?
    private var onCoverTap: (() -> Void)?
    
    private var leadingConstraint: NSLayoutConstraint?
    private var centerConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    
    private var fullHeightConstraint: NSLayoutConstraint?
    private var converViewHeightConstraint: NSLayoutConstraint?
    private var iconTopConstraint: NSLayoutConstraint?
    private var coverBottomConstraint: NSLayoutConstraint?
    private var iconBottomConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        coverViewCenter = coverView.layer.position
    }

    // MARK: - Internal functions
    private lazy var coverViewCenter: CGPoint = coverView.layer.position

    func applyCoverTransform(_ transform: CGAffineTransform) {
        if coverView.transform.isIdentity, !transform.isIdentity {
            let maxY = coverViewCenter.y + coverView.bounds.height / 2
            coverView.layer.position = CGPoint(x: coverViewCenter.x, y: maxY)
            coverView.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        } else if transform.isIdentity {
            coverView.layer.position = coverViewCenter
            coverView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }

//         Disable CALayer implicit animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        coverView.transform = transform

        CATransaction.commit()
    }
}

extension ObjectHeaderView: ConfigurableView {
    
    struct Model {
        let state: ObjectHeaderFilledState
        let sizeConfiguration: HeaderViewSizeConfiguration
        let isShimmering: Bool
    }
    
    func configure(model: Model) {
        update(sizeConfiguration: model.sizeConfiguration)
        iconView.initialBorderWidth = model.sizeConfiguration.iconBorderWidth
        
        switch model.state {
        case .iconOnly(let objectHeaderIconState):
            switchState(.icon)
            applyObjectHeaderIcon(objectHeaderIconState.icon)
            onCoverTap = objectHeaderIconState.onCoverTap
            
        case .coverOnly(let objectHeaderCover):
            switchState(.cover)
            
            applyObjectHeaderCover(objectHeaderCover, sizeConfiguration: model.sizeConfiguration)
            
        case .iconAndCover(let objectHeaderIcon, let objectHeaderCover):
            switchState(.iconAndCover)
            
            applyObjectHeaderIcon(objectHeaderIcon)
            applyObjectHeaderCover(objectHeaderCover, sizeConfiguration: model.sizeConfiguration)
        }
    }
    
    private func switchState(_ state: State) {
        let isIcon = state == .icon
        fullHeightConstraint?.isActive = !isIcon
        iconTopConstraint?.isActive = isIcon
        converViewHeightConstraint?.isActive = !isIcon
        
        switch state {
        case .icon:
            iconView.isHidden = false
            coverView.isHidden = true
        case .cover:
            iconView.isHidden = true
            coverView.isHidden = false
        case .iconAndCover:
            iconView.isHidden = false
            coverView.isHidden = false
        }
    }
    
    private func applyObjectHeaderIcon(_ objectHeaderIcon: ObjectHeaderIcon) {
        iconView.configure(model: objectHeaderIcon.icon)
        applyLayoutAlignment(objectHeaderIcon.layoutAlignment)
        onIconTap = objectHeaderIcon.onTap
    }
    
    private func applyLayoutAlignment(_ layoutAlignment: LayoutAlignment) {
        switch layoutAlignment {
        case .left:
            leadingConstraint?.isActive = true
            centerConstraint?.isActive = false
            trailingConstraint?.isActive = false
        case .center:
            leadingConstraint?.isActive = false
            centerConstraint?.isActive = true
            trailingConstraint?.isActive = false
        case .right:
            leadingConstraint?.isActive = false
            centerConstraint?.isActive = false
            trailingConstraint?.isActive = true
        }
    }
    
    private func applyObjectHeaderCover(
        _ objectHeaderCover: ObjectHeaderCover,
        sizeConfiguration: HeaderViewSizeConfiguration
    ) {
        coverView.configure(
            model: ObjectHeaderCoverView.Model(
                objectCover: objectHeaderCover.coverType,
                size: CGSize(
                    width: sizeConfiguration.width,
                    height: sizeConfiguration.coverHeight
                ),
                fitImage: false
            )
        )

        onCoverTap = objectHeaderCover.onTap
    }
    
    private func update(sizeConfiguration: HeaderViewSizeConfiguration) {
        fullHeightConstraint?.constant = sizeConfiguration.fullHeight
        coverBottomConstraint?.constant = -sizeConfiguration.coverBottomInset
        converViewHeightConstraint?.constant = sizeConfiguration.coverHeight
        iconBottomConstraint?.constant = -sizeConfiguration.iconBottomInset
        leadingConstraint?.constant = sizeConfiguration.iconHorizontalInset
        trailingConstraint?.constant = -sizeConfiguration.iconHorizontalInset
        iconTopConstraint?.constant = sizeConfiguration.onlyIconTopInset
    }
    
}

private extension ObjectHeaderView {
    
    func setupView() {
        backgroundColor = .Background.primary
        setupGestureRecognizers()
        
        setupLayout()
        
        iconView.isHidden = true
        coverView.isHidden = true
    }
    
    func setupGestureRecognizers() {
        iconView.addGestureRecognizer(
            TapGestureRecognizerWithClosure { [weak self] in
                self?.onIconTap?()
            }
        )
        
        addGestureRecognizer(
            TapGestureRecognizerWithClosure { [weak self] in
                self?.onCoverTap?()
            }
        )
    }
    
    func setupLayout() {
        layoutUsing.anchors {
            fullHeightConstraint = $0.height.equal(to: 0, priority: .defaultLow)
        }

        addSubview(coverView) {
            $0.pinToSuperview(
                excluding: [.bottom],
                insets: .zero
            )
            coverBottomConstraint = $0.bottom.greaterThanOrEqual(
                to: bottomAnchor,
                constant: 0,
                priority: .init(rawValue: 999)
            )
            converViewHeightConstraint = $0.height.equal(to: 0)
        }
        
        addSubview(iconView) {
            iconBottomConstraint = $0.bottom.equal(
                to: bottomAnchor,
                constant: 0
            )

            leadingConstraint = $0.leading.equal(
                to: leadingAnchor,
                constant: 0,
                activate: false
            )

            centerConstraint = $0.centerX.equal(
                to: centerXAnchor,
                activate: false
            )
            
            trailingConstraint =  $0.trailing.equal(
                to: trailingAnchor,
                constant: 0,
                activate: false
            )
            
            iconTopConstraint = $0.top.equal(
                to: topAnchor,
                constant: 0
            )
        }
    }
}

extension ObjectHeaderView {
    
    enum State {
        case icon
        case cover
        case iconAndCover
    }
    
}
