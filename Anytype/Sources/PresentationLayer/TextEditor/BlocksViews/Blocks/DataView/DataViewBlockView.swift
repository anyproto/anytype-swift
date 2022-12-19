import Combine
import UIKit
import BlocksModels
import AnytypeCore

final class DataViewBlockView: UIView, BlockContentView {
    private let iconView = ObjectIconImageView()
    private let titleLabel: AnytypeLabel = {
        let title = AnytypeLabel(style: .subheading)
        title.numberOfLines = 1
        title.textColor = .textPrimary
        return title
    }()
    private let subtitleLabel: AnytypeLabel = {
        let subtitleLabel = AnytypeLabel(style: .relation3Regular)
        subtitleLabel.textColor = .textSecondary
        subtitleLabel.setText(Loc.Content.DataView.inlineSet)
        return subtitleLabel
    }()
    private let contentView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.dynamicBorderColor = UIColor.strokePrimary
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    private let deletedLabel = DeletedLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func update(with configuration: DataViewBlockConfiguration) {
        if let iconImage = configuration.iconImage {
            iconView.configure(
                model: ObjectIconImageModel(iconImage: iconImage, usecase: .editorCalloutBlock)
            )
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }
        titleLabel.setText(configuration.title)
    }

    private func setup() {
        addSubview(contentView) {
            $0.pinToSuperview(insets: Layout.contentViewInsets)
        }
        contentView.layoutUsing.stack {
            $0.hStack(
                $0.hGap(fixed: Layout.contentInnerInsets.left),
                $0.vStack(
                    $0.vGap(fixed: Layout.contentInnerInsets.top),
                    $0.hStack(spacing: 6,
                        iconView,
                        titleLabel
                    ),
                    $0.vGap(fixed: 4),
                    subtitleLabel,
                    $0.vGap(fixed: Layout.contentInnerInsets.bottom)
                ),
                $0.hGap(fixed: Layout.contentInnerInsets.right)
            )
        }
        iconView.layoutUsing.anchors {
            $0.size(Layout.iconViewSize)
        }
    }
}

private extension DataViewBlockView {
    enum Layout {
        static let contentViewInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        static let contentInnerInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        static let iconViewSize = CGSize(width: 20, height: 24)
    }
}
