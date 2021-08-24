
import UIKit

final class ContentViewWithEmoji: UIView, UIContentView {
    
    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let emojiSize = CGSize(width: 40, height: 40)
        static let imagePadding = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 12)
        static let labelsPadding: CGFloat = -4
        static let labelsTrailingPadding: CGFloat = 16
        static let labelsVerticalPadding: CGFloat = 8.5
    }
    
    var configuration: UIContentConfiguration {
        get  { currentConfiguration }
        set {
            guard let configuration = newValue as? ContentConfigurationWithEmoji,
                  configuration != currentConfiguration else { return }
            currentConfiguration = configuration
            applyNewConfiguration()
        }
    }
    private var currentConfiguration: ContentConfigurationWithEmoji
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .previewTitle2Regular
        label.textColor = .textPrimary
        return label
    }()
    private let subtitleLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .relation2Regular
        label.textColor = .textSecondary
        return label
    }()
    private let emojiView: DocumentIconEmojiView = {
        let view = DocumentIconEmojiView(
            font: .systemFont(ofSize: 23),
            cornerRadius: Constants.cornerRadius,
            size: Constants.emojiSize
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(contentConfiguration: ContentConfigurationWithEmoji) {
        self.currentConfiguration = contentConfiguration
        super.init(frame: .zero)
        setup()
        applyNewConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(emojiView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            emojiView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: Constants.imagePadding.left),
            emojiView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor,
                                                constant: -Constants.imagePadding.right),
            emojiView.topAnchor.constraint(equalTo: topAnchor,
                                           constant: Constants.imagePadding.top),
            emojiView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                              constant: -Constants.imagePadding.bottom),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.labelsVerticalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.labelsTrailingPadding),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: Constants.labelsPadding),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.labelsVerticalPadding),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.labelsTrailingPadding)
        ])
    }
    
    private func applyNewConfiguration() {
        emojiView.configure(model: currentConfiguration.emoji)
        titleLabel.text = currentConfiguration.name
        subtitleLabel.text = currentConfiguration.description
    }
}
