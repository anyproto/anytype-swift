import Combine
import Services
import UIKit
import AnytypeCore

class UnsupportedBlockView: UIView, BlockContentView {
    private let label: AnytypeLabel = {
        let label = AnytypeLabel(style: .calloutRegular)
        label.textColor = .Text.tertiary
        return label
    }()

    private let icon: UIImageView = {
        let imageView = UIImageView(asset: .X18.help)
        imageView.tintColor = .Control.secondary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }


    func update(with configuration: UnsupportedBlockContentConfiguration) {
        apply(configuration: configuration)
    }

    private func setup() {
        addSubview(icon) {
            $0.leading.equal(to: leadingAnchor, constant: Layout.iconLeftSpacing)
            $0.height.equal(to: Layout.iconSize)
            $0.width.equal(to: Layout.iconSize)
            $0.centerY.equal(to: centerYAnchor)
        }

        addSubview(label) {
            $0.top.equal(to: topAnchor, constant: Layout.labelTopBottomSpacing)
            $0.bottom.equal(to: bottomAnchor, constant: -Layout.labelTopBottomSpacing)
            $0.leading.equal(to: icon.trailingAnchor, constant: Layout.iconToTextPadding)
            $0.trailing.equal(to: trailingAnchor, constant: -Layout.labelTrailingSpacing)
        }
    }

    // MARK: - New configuration
    func apply(configuration: UnsupportedBlockContentConfiguration) {
        label.setText(configuration.text)
    }
}


extension UnsupportedBlockView {
    private enum Layout {
        static let labelTrailingSpacing: CGFloat = 0
        static let labelTopBottomSpacing: CGFloat = 5
        static let iconToTextPadding: CGFloat = 9
        static let iconSize: CGFloat =  18
        static let iconLeftSpacing: CGFloat =  23.11
    }
}
