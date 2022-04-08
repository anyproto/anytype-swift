import UIKit
import Combine
import BlocksModels
import Kingfisher

final class BlockLinkView: UIView, BlockContentView {
    
    // MARK: - Views
    
    private var hGap: FixedGapViewConstraintProtocol!
    private var vGap: FixedGapViewConstraintProtocol!
    private var iconContainerTopConstraint: NSLayoutConstraint!
    private var iconContainerLeadingConstraint: NSLayoutConstraint!

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

        descriptionView.isHidden = !configuration.state.hasDescription
        descriptionView.setText(configuration.state.attributedDescription)
    }
    
}

// MARK: - Private functions

private extension BlockLinkView {
    
    func setup() {
        addSubview(contentView) {
            $0.pinToSuperview()
        }

        stackView = contentView.layoutUsing.stack {
            $0.hStack(
                iconContainerView,
                $0.hGap(fixed: .zero) {  [weak self] view in
                    self?.hGap = view
                },
                $0.vStack(
                    $0.hStack(
                        titleView,
                        $0.hGap(),
                        deletedLabel
                    ),
                    $0.vGap(fixed: .zero, relatedTo: descriptionView) { [weak self] view in
                        self?.vGap = view
                    },
                    descriptionView
                )
            )
        }

        iconContainerView.layoutUsing.anchors {
            iconContainerTopConstraint = $0.top.equal(to: stackView.topAnchor)
            iconContainerLeadingConstraint = $0.leading.equal(to: stackView.leadingAnchor)
        }
    }

    func setLayout(configuration: BlockLinkContentConfiguration) {
        guard !configuration.state.deleted else {
            setupTextLayout()
            return
        }

        let layout = configuration.state.objectPreviewFields.layout

        switch layout {
        case .text:
            setupTextLayout()
        case .card:
            setupCardLayout(backgroundColor: configuration.backgroundColor)
        }
    }

    func setupTextLayout() {
        contentView.layer.borderColor = nil
        contentView.layer.borderWidth = 0.0
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 0
        stackView.alignment = Constants.TextLayout.stackAlignment
        vGap.fixedConstraint?.constant = Constants.TextLayout.vGapImageText
        hGap.fixedConstraint?.constant = Constants.TextLayout.hGapImageText
        iconContainerTopConstraint.constant = Constants.TextLayout.imageContainerEdgeInset
        iconContainerLeadingConstraint.constant = Constants.TextLayout.imageContainerEdgeInset
    }

    func setupCardLayout(backgroundColor: UIColor) {
        contentView.backgroundColor = backgroundColor
        if backgroundColor == .clear {
            contentView.layer.borderColor = UIColor.strokePrimary.cgColor
            contentView.layer.borderWidth = 0.5
        }
        contentView.layer.cornerRadius = 16
        stackView.alignment = Constants.CardLayout.stackAlignment
        vGap.fixedConstraint?.constant = Constants.CardLayout.vGapImageText
        hGap.fixedConstraint?.constant = Constants.CardLayout.hGapImageText
        iconContainerTopConstraint.constant = Constants.CardLayout.imageContainerEdgeInset
        iconContainerLeadingConstraint.constant = Constants.CardLayout.imageContainerEdgeInset
    }
    
}
// MARK: - Constants

private extension BlockLinkView {
    
    enum Constants {

        enum TextLayout {
            static let imageContainerEdgeInset: CGFloat = 0
            static let hGapImageText: CGFloat = 8
            static let vGapImageText: CGFloat = 2
            static let stackAlignment: UIStackView.Alignment = .top
        }

        enum CardLayout {
            static let imageContainerEdgeInset: CGFloat = 16
            static let hGapImageText: CGFloat = 12
            static let vGapImageText: CGFloat = 4
            static let stackAlignment: UIStackView.Alignment = .center
        }
    }
    
}
