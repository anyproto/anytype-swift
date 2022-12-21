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

    private var titleTopConstraint: NSLayoutConstraint!

    private func setup() {
        addSubview(container) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            $0.height.equal(to: 56)
        }
        
        container.addSubview(icon) {
            $0.centerY.equal(to: container.centerYAnchor)
            $0.leading.equal(to: container.leadingAnchor)
            $0.height.equal(to: 40)
            $0.width.equal(to: 40)
        }

        container.addSubview(title) {
            titleTopConstraint = $0.top.equal(to: container.topAnchor, constant: titleWithSubtitleTop)
            $0.leading.equal(to: icon.trailingAnchor, constant: 12)
            $0.trailing.equal(to: container.trailingAnchor)
        }

        container.addSubview(subtitle) {
            $0.top.equal(to: title.bottomAnchor)
            $0.leading.equal(to: icon.trailingAnchor, constant: 12)
            $0.bottom.equal(to: container.bottomAnchor, priority: .defaultLow)
            $0.trailing.equal(to: container.trailingAnchor)
        }
    }
    
    private func apply(configuration: EditorSearchCellConfiguration) {
        icon.configure(
            model: ObjectIconImageView.Model(
                iconImage: configuration.cellData.icon,
                usecase: configuration.cellData.expandedIcon ? .editorSearchExpandedIcons : .editorSearch
            )
        )

        title.setText(configuration.cellData.title, style: .uxTitle2Regular)
        
        if configuration.cellData.subtitle.isNotEmpty {
            subtitle.isHidden = false
            titleTopConstraint.constant = titleWithSubtitleTop
            subtitle.setText(configuration.cellData.subtitle, style: .caption1Regular)
        } else {
            subtitle.isHidden = true
            titleTopConstraint.constant = titleWithoutSubtitleTop
        }
    }
    
    // MARK: - Views
    private let container = UIView()
    private let icon = ObjectIconImageView()
    private let title: AnytypeLabel = {
        let title = AnytypeLabel(style: .uxTitle2Regular)
        title.textColor = .Text.primary
        title.numberOfLines = 1
        return title
    }()
    private let subtitle: AnytypeLabel = {
        let subtitle = AnytypeLabel(style: .caption1Regular)
        subtitle.textColor = .Text.secondary
        subtitle.numberOfLines = 1
        return subtitle
    }()
    
    // MARK: - Constants
    private let titleWithSubtitleTop: CGFloat = 9
    private let titleWithoutSubtitleTop: CGFloat = 18
    
    
    // MARK: - Not implemented
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
