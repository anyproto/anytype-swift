import UIKit
import Combine
import BlocksModels
import Kingfisher

final class BlockLinkView: UIView, BlockContentView {
    
    // MARK: - Views
    
    private var hGap: FixedGapViewConstraintProtocol!
    private var vGap: FixedGapViewConstraintProtocol!
    private var containerHeightConstraint: NSLayoutConstraint!

    private var iconContainerLeadingConstraint: NSLayoutConstraint!
    private var iconContainerTopConstraint: NSLayoutConstraint!
    private var iconContainerCenterConstraint: NSLayoutConstraint!

    private var stackViewTrailingConstraint: NSLayoutConstraint!
    private var stackViewTopConstraint: NSLayoutConstraint!
    private var stackViewBottomConstraint: NSLayoutConstraint!

    private let contentView = UIView()
    private let iconContainerView = UIView()
    private var stackView: UIStackView!

    private let deletedLabel = DeletedLabel()
    
    private let titleView: AnytypeLabel = {
        let view = AnytypeLabel(style: .body)
        view.isUserInteractionEnabled = false
        return view
    }()

    private let descriptionView: AnytypeLabel = {
        let view = AnytypeLabel(style: .relation2Regular)
        view.numberOfLines = 2
        view.isUserInteractionEnabled = false
        return view
    }()

    private let typeView: AnytypeLabel = {
        let view = AnytypeLabel(style: .relation2Regular)
        view.numberOfLines = 1
        view.isUserInteractionEnabled = false
        return view
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Internal functions
    
    func update(with configuration: BlockLinkContentConfiguration) {
        apply(configuration)
    }

    func apply(_ configuration: BlockLinkContentConfiguration) {
        setLayout(configuration: configuration)

        iconContainerView.removeAllSubviews()
        if let iconView = configuration.state.makeIconView() {
            iconContainerView.addSubview(iconView) {
                $0.pinToSuperview()
            }
            iconContainerView.isHidden = false
        } else {
            iconContainerView.isHidden = true
        }

        titleView.setText(configuration.state.attributedTitle)
        titleView.setLineBreakMode(.byTruncatingTail)
        deletedLabel.isHidden = !configuration.state.archived

        descriptionView.isHidden = configuration.state.description.isEmpty
        descriptionView.setText(configuration.state.attributedDescription)
        descriptionView.setLineBreakMode(.byTruncatingTail)

        typeView.isHidden = !configuration.state.relations.contains(.type)
        typeView.setText(configuration.state.attributedType)
    }
    
}

// MARK: - Private functions

private extension BlockLinkView {
    
    func setup() {
        addSubview(contentView) {
            $0.pinToSuperview(excluding: [.bottom], insets: .init(top: 5, left: 0, bottom: -5, right: 0))
            $0.bottom.equal(to: bottomAnchor, priority: .defaultLow)
        }
        containerHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.CardLayout.containerHeight)

        contentView.addSubview(iconContainerView) {
            iconContainerTopConstraint = $0.top.equal(to: contentView.topAnchor)
            iconContainerCenterConstraint = $0.centerY.equal(to: contentView.centerYAnchor)
            iconContainerLeadingConstraint = $0.leading.equal(to: contentView.leadingAnchor)
        }

        stackView = contentView.layoutUsing.stack { [weak self] in
            guard let self = self else { return }
            $0.layoutUsing.anchors {
                $0.leading.equal(to: self.iconContainerView.trailingAnchor)
                self.stackViewTopConstraint = $0.top.equal(to: self.contentView.topAnchor)
                self.stackViewTrailingConstraint = $0.trailing.equal(to: self.contentView.trailingAnchor)
                self.stackViewBottomConstraint = $0.bottom.equal(to: self.contentView.bottomAnchor)
            }
        } builder: {
            $0.hStack(
                $0.hGap(fixed: .zero, relatedTo: iconContainerView) {  [weak self] view in
                    self?.hGap = view
                },
                $0.vStack(
                    $0.hStack(
                        alignedTo: .leading,
                        titleView,
                        $0.hGap(),
                        deletedLabel
                    ),
                    $0.vGap(fixed: .zero, relatedTo: descriptionView) { [weak self] view in
                        self?.vGap = view
                    },
                    descriptionView,

                    $0.vGap(fixed: .zero, relatedTo: typeView) { [weak self] view in
                        self?.vGap = view
                    },
                    typeView
                )
            )
        }
        
        deletedLabel.horizontalCompressionResistancePriority = .required
    }

    func setLayout(configuration: BlockLinkContentConfiguration) {
        if let backgroundColor = configuration.backgroundColor, backgroundColor != .backgroundPrimary {
            contentView.backgroundColor = backgroundColor
            contentView.layer.borderWidth = .zero
        } else {
            contentView.backgroundColor = nil
            contentView.dynamicBorderColor = UIColor.strokePrimary
            contentView.layer.borderWidth = 1
        }

        guard !configuration.state.deleted else {
            setupTextLayout()
            return
        }

        let layout = configuration.state.cardStyle

        switch layout {
        case .text:
            setupTextLayout()
        case .card:
            setupCardLayout(backgroundColor: configuration.backgroundColor, iconInCenterY: configuration.state.style.isCheckmark)
        }
    }

    func setupTextLayout() {
        contentView.layer.cornerRadius = 0
        contentView.layer.borderWidth = .zero
        containerHeightConstraint.isActive = false
        stackView.alignment = Constants.TextLayout.stackAlignment
        titleView.numberOfLines = 1
        vGap.fixedConstraint?.constant = Constants.TextLayout.vGapImageText
        hGap.fixedConstraint?.constant = Constants.TextLayout.hGapImageText

        iconContainerLeadingConstraint.constant = Constants.TextLayout.stackViewEdgeInsets.left
        iconContainerTopConstraint.constant = Constants.TextLayout.stackViewEdgeInsets.top
        iconContainerTopConstraint.isActive = true
        iconContainerCenterConstraint.isActive = false

        stackViewTrailingConstraint.constant = Constants.TextLayout.stackViewEdgeInsets.right
        stackViewTopConstraint.constant = Constants.TextLayout.stackViewEdgeInsets.top
        stackViewBottomConstraint.constant = Constants.TextLayout.stackViewEdgeInsets.bottom
    }

    func setupCardLayout(backgroundColor: UIColor?, iconInCenterY: Bool) {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        containerHeightConstraint.isActive = true
        titleView.numberOfLines = 2
        stackView.alignment = Constants.CardLayout.stackAlignment
        vGap.fixedConstraint?.constant = Constants.CardLayout.vGapImageText
        hGap.fixedConstraint?.constant = Constants.CardLayout.hGapImageText

        iconContainerLeadingConstraint.constant = Constants.CardLayout.stackViewEdgeInsets.left

        iconContainerTopConstraint.isActive = !iconInCenterY
        iconContainerCenterConstraint.isActive = iconInCenterY
        iconContainerTopConstraint.constant = Constants.CardLayout.stackViewEdgeInsets.top

        stackViewTrailingConstraint.constant = Constants.CardLayout.stackViewEdgeInsets.right
        stackViewTopConstraint.constant = Constants.CardLayout.stackViewEdgeInsets.top
        stackViewBottomConstraint.constant = Constants.CardLayout.stackViewEdgeInsets.bottom
    }
    
}
// MARK: - Constants

private extension BlockLinkView {
    
    enum Constants {

        enum TextLayout {
            static let stackViewEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
            static let imageContainerEdgeInset: CGFloat = 0
            static let hGapImageText: CGFloat = 8
            static let vGapImageText: CGFloat = 2
            static let stackAlignment: UIStackView.Alignment = .top
        }

        enum CardLayout {
            static let stackViewEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16)
            static let containerHeight: CGFloat = 96
            static let imageContainerEdgeInset: CGFloat = 16
            static let hGapImageText: CGFloat = 12
            static let vGapImageText: CGFloat = 4
            static let stackAlignment: UIStackView.Alignment = .center
        }
    }
    
}
