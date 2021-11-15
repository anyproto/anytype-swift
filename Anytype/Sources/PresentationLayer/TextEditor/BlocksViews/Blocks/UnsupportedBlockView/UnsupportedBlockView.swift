import Combine
import BlocksModels
import UIKit
import AnytypeCore

class UnsupportedBlockView: BaseBlockView<UnsupportedBlockContentConfiguration> {
    private let label: AnytypeLabel = {
        let label = AnytypeLabel(style: .callout)
        label.textColor = .textTertiary
        return label
    }()

    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "TextEditor/questionMark")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func update(with configuration: UnsupportedBlockContentConfiguration) {
        super.update(with: configuration)

        apply(configuration: configuration)
    }

    override func setupSubviews() {
        super.setupSubviews()
        setup()
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
        static let labelTrailingSpacing: CGFloat = 20
        static let labelTopBottomSpacing: CGFloat = 5
        static let iconToTextPadding: CGFloat = 9
        static let iconSize: CGFloat =  18
        static let iconLeftSpacing: CGFloat =  23.11
    }
}
