import Foundation
import UIKit
import BlocksModels
import AnytypeCore

final class ObjectHeaderView: UIView {
    
    // MARK: - Private variables

    private let iconView = ObjectHeaderIconView()
    private let coverView = ObjectHeaderCoverView()
    
    private var onIconTap: (() -> Void)?
    private var onCoverTap: (() -> Void)?
    
    private var leadingConstraint: NSLayoutConstraint!
    private var centerConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    init(topAdjustedContentInset: CGFloat) {
        super.init(frame: .zero)

        setupView(topAdjustedContentInset: topAdjustedContentInset)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        // Disable CALayer implicit animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        coverView.transform = transform

        CATransaction.commit()
    }
}

extension ObjectHeaderView: ConfigurableView {
    
    struct Model {
        let state: ObjectHeaderFilledState
        let width: CGFloat
    }
    
    func configure(model: Model) {
        switch model.state {
        case .iconOnly(let objectHeaderIconState):
            switchState(.icon)
            applyObjectHeaderIcon(objectHeaderIconState.icon)
            onCoverTap = objectHeaderIconState.onCoverTap
            
        case .coverOnly(let objectHeaderCover):
            switchState(.cover)
            
            applyObjectHeaderCover(objectHeaderCover, maxWidth: model.width)
            
        case .iconAndCover(let objectHeaderIcon, let objectHeaderCover):
            switchState(.iconAndCover)
            
            applyObjectHeaderIcon(objectHeaderIcon)
            applyObjectHeaderCover(objectHeaderCover, maxWidth: model.width)
        }
    }
    
    private func switchState(_ state: State) {
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
            leadingConstraint.isActive = true
            centerConstraint.isActive = false
            trailingConstraint.isActive = false
        case .center:
            leadingConstraint.isActive = false
            centerConstraint.isActive = true
            trailingConstraint.isActive = false
        case .right:
            leadingConstraint.isActive = false
            centerConstraint.isActive = false
            trailingConstraint.isActive = true
        }
    }
    
    private func applyObjectHeaderCover(_ objectHeaderCover: ObjectHeaderCover, maxWidth: CGFloat) {
        coverView.configure(
            model: ObjectHeaderCoverView.Model(
                objectCover: objectHeaderCover.coverType,
                size: CGSize(
                    width: maxWidth,
                    height: ObjectHeaderConstants.coverHeight
                )
            )
        )
        onCoverTap = objectHeaderCover.onTap
    }
    
}

private extension ObjectHeaderView {
    
    func setupView(topAdjustedContentInset: CGFloat) {
        backgroundColor = .backgroundPrimary
        setupGestureRecognizers()
        
        setupLayout(topAdjustedContentInset: topAdjustedContentInset)
        
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
    
    func setupLayout(topAdjustedContentInset: CGFloat) {
        layoutUsing.anchors {
            $0.height.equal(to: ObjectHeaderConstants.height, priority: .defaultLow)
        }
        
        addSubview(coverView) {
            $0.pinToSuperview(excluding: [.top, .bottom])
            $0.bottom.equal(to: bottomAnchor, constant: -ObjectHeaderConstants.coverBottomInset)
            $0.height.equal(to: ObjectHeaderConstants.coverHeight + topAdjustedContentInset)
        }
        
        addSubview(iconView) {
            $0.bottom.equal(
                to: bottomAnchor,
                constant: -ObjectHeaderConstants.iconBottomInset
            )

            leadingConstraint = $0.leading.equal(
                to: leadingAnchor,
                constant: ObjectHeaderConstants.iconHorizontalInset,
                activate: false
            )

            centerConstraint = $0.centerX.equal(
                to: centerXAnchor,
                activate: false
            )
            
            trailingConstraint =  $0.trailing.equal(
                to: trailingAnchor,
                constant: -ObjectHeaderConstants.iconHorizontalInset,
                activate: false
            )
        }
    }
    
}

private extension ObjectHeaderView {
    
    enum State {
        case icon
        case cover
        case iconAndCover
    }
    
}
