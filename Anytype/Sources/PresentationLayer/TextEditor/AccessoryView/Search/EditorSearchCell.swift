// https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=137%3A949

import UIKit

final class EditorSearchCell: UIView, UIContentView {
    private var currentConfiguration: EditorSearchCellConfiguration
    var configuration: any UIContentConfiguration {
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
            $0.pinToSuperview(insets: UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20))
        }
        
        icon.widthAnchor.constraint(equalToConstant: 40).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        container.layoutUsing.stack {
            $0.hStack(
                spacing: 12,
                alignedTo: .center,
                icon,
                $0.vStack(
                    title,
                    subtitle
                )
            )
        }
    }
    
    private func apply(configuration: EditorSearchCellConfiguration) {
        icon.icon = configuration.cellData.icon
        icon.isHidden = configuration.cellData.icon.isNil
        title.setText(configuration.cellData.title, style: .uxTitle2Medium)
        
        if configuration.cellData.subtitle.isNotEmpty {
            subtitle.isHidden = false
            subtitle.setText(configuration.cellData.subtitle, style: .relation2Regular)
        } else {
            subtitle.isHidden = true
        }
    }
    
    // MARK: - Views
    private let container = UIView()
    private let icon = IconViewUIKit()
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
    
    // MARK: - Not implemented
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
