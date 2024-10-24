import UIKit

final class UISectionHeader: UIView, UIContentView {
    private var currentConfiguration: UISectionHeaderConfiguration
    var configuration: any UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfig = newValue as? UISectionHeaderConfiguration else { return }
            apply(configuration: newConfig)
        }
    }
    
    private let title: AnytypeLabel = {
        let title = AnytypeLabel(style: .relation2Regular)
        title.textColor = .Text.secondary
        title.numberOfLines = 1
        return title
    }()
    
    init(configuration: UISectionHeaderConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        
        setup()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(title) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 14, left: 20, bottom: 4, right: 20))
        }
    }
    
    private func apply(configuration: UISectionHeaderConfiguration) {
        title.setText(configuration.title)
    }
}
