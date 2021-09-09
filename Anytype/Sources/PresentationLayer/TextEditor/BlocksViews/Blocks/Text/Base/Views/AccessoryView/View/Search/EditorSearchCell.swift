// https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=137%3A949

import UIKit

final class EditorSearchCell: UIView, UIContentView {
    private var currentConfiguration: EditorSearchCellConfiguration
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? EditorSearchCellConfiguration else {
                return
            }
            guard configuration != currentConfiguration else {
                return
            }
            
            currentConfiguration = configuration
            apply(configuration: configuration)
        }
    }
    
    init(configuration: EditorSearchCellConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        
        setup()
        apply(configuration: configuration)
    }
    
    private func setup() {        
        addSubview(container) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20))
            $0.height.equal(to: 56)
        }
        
        container.addSubview(icon) {
            $0.centerY.equal(to: container.centerYAnchor)
            $0.leading.equal(to: container.leadingAnchor)
            $0.height.equal(to: 40)
            $0.width.equal(to: 40)
        }

        let titleText = UIKitAnytypeText(text: "", style: .uxTitle2Regular)
        container.addSubview(title) {
            $0.top.equal(to: container.topAnchor,constant: 9 + titleText.verticalSpacing)
            $0.leading.equal(to: icon.trailingAnchor, constant: 12)
            $0.trailing.equal(to: container.trailingAnchor)
        }
        
        let subtitleText = UIKitAnytypeText(text: "", style: .caption1Regular)
        container.addSubview(subtitle) {
            $0.top.equal(
                to: title.bottomAnchor,
                constant: titleText.verticalSpacing + subtitleText.verticalSpacing
            )
            $0.leading.equal(to: icon.trailingAnchor, constant: 12)
            $0.bottom.equal(
                to: container.bottomAnchor,
                constant: -9 - subtitleText.verticalSpacing,
                priority: .defaultLow
            )
            $0.trailing.equal(to: container.trailingAnchor)
        }
    }
    
    private func apply(configuration: EditorSearchCellConfiguration) {
        icon.configure(
            model: ObjectIconImageView.Model(
                iconImage: configuration.cellData.icon,
                usecase: .editorSearch
            )
        )

        title.attributedText = UIKitAnytypeText(text: configuration.cellData.title, style: .uxTitle2Regular).attrString
        subtitle.attributedText = UIKitAnytypeText(text: configuration.cellData.subtitle, style: .caption1Regular).attrString
    }
    
    private let container = UIView()
    private let icon = ObjectIconImageView()
    private let title: UILabel = {
        let title = UILabel()
        title.textColor = .textPrimary
        title.numberOfLines = 1
        return title
    }()
    private let subtitle: UILabel = {
        let subtitle = UILabel()
        subtitle.textColor = .textSecondary
        subtitle.numberOfLines = 1
        return subtitle
    }()
    
    // MARK: - Not implemented
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
