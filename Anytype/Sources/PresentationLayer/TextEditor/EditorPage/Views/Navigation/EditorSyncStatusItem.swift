import UIKit
import Services

final class EditorSyncStatusItem: UIView {
    private let backgroundView = UIView()
    private let button: UIButton = {
        let configuration = UIButton.Configuration.plain()
        
        return UIButton(configuration: configuration)
    }()
    
    private var status: SyncStatus
    private var state = EditorBarItemState.initial
    
    private let height: CGFloat = 28
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
    
    func changeState(_ state: EditorBarItemState) {
        self.state = state
        updateState()
        updateIntristicSize()
    }
    
    func changeStatus(_ status: SyncStatus) {
        self.status = status
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
            self.updateButtonState()
        }
        updateIntristicSize()
    }
    
    init(status: SyncStatus) {
        self.status = status
        super.init(frame: .zero)
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        intristicSize
    }
    
    // MARK: - Private
    
    private func setup() {
        backgroundView.backgroundColor = .black.withAlphaComponent(0.35)
        backgroundView.layer.cornerRadius = 7
        
        button.setImageAndTitleSpacing(6)
        button.showsMenuAsPrimaryAction = true
        
        updateButtonState()
        
        layoutUsing.anchors {
            $0.height.equal(to: height)
            $0.centerY.equal(to: centerYAnchor)
        }
        
        addSubview(backgroundView) {
            $0.pinToSuperview()
        }
        
        addSubview(button) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 9, bottom: 0, right: 10))
        }
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
    }
    
    private func updateButtonState() {
        updateTitle()
        var configuration = button.configuration
        
        configuration?.image = status.image
        button.menu = UIMenu(title: "", children: [ UIAction(title: status.description) { _ in } ] )
        
        button.configuration = configuration
    }
    
    private func updateState() {
        backgroundView.alpha = state.backgroundAlpha
        updateTitle()
    }
    
    private func updateTitle() {
        var configuration = button.configuration
        
        button.setTitleColor(state.hiddableTextColor, for: .normal)

        configuration?.attributedTitle = buttonAttributedString(
            with: state.textIsHidden ? nil : status.title,
            textColor: state.hiddableTextColor
        )
        
        button.configuration = configuration
    }
    
    private func updateIntristicSize() {
        intristicSize = systemLayoutSizeFitting(
            CGSize(width: .zero, height: height),
            withHorizontalFittingPriority: .defaultHigh,
            verticalFittingPriority: .fittingSizeLevel
        )
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Unavailable
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
