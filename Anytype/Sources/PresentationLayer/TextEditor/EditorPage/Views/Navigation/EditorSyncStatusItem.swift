import UIKit
import Services

final class EditorSyncStatusItem: UIView {
    private let button: UIButton = {
        let configuration = UIButton.Configuration.plain()
        
        return UIButton(configuration: configuration)
    }()
    
    private var statusData: SyncStatusData?
    
    private let height: CGFloat = 28
    private let width: CGFloat = 28
    private var intristicSize: CGSize = .zero
    
    private func buttonAttributedString(with title: String?, textColor: UIColor) -> AttributedString {
        AttributedString(
            title ?? "",
            attributes: AttributeContainer([
                NSAttributedString.Key.font: AnytypeFont.caption1Regular.uiKitFont,
                NSAttributedString.Key.foregroundColor: textColor
            ])
        )
    }
    
    func changeStatusData(_ statusData: SyncStatusData) {
        self.statusData = statusData
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
            self.updateButtonState()
        }
        updateIntristicSize()
    }
    
    init(statusData: SyncStatusData? = nil) {
        self.statusData = statusData
        super.init(frame: .zero)
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        intristicSize
    }
    
    // MARK: - Private
    
    private func setup() {
        button.showsMenuAsPrimaryAction = true
        
        updateButtonState()
        
        layoutUsing.anchors {
            $0.height.equal(to: height)
            $0.width.equal(to: width)
            $0.centerY.equal(to: centerYAnchor)
        }
        
        addSubview(button) { $0.pinToSuperview() }
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
    }
    
    private func updateButtonState() {
        var configuration = button.configuration
        
        configuration?.image = statusData?.image
        button.configuration = configuration
        isHidden = statusData?.isHidden ?? true
    }
    
        
        
        button.configuration = configuration
    }
    
    }
    
    // MARK: - Unavailable
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
