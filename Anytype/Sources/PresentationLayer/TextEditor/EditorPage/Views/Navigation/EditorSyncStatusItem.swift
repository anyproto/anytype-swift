import UIKit
import BlocksModels

final class EditorSyncStatusItem: UIView {
    private let backgroundView = UIView()
    private let button = UIButton(type: .custom)
    
    private var status: SyncStatus
    private var state = EditorBarItemState.initial
    
    func changeState(_ state: EditorBarItemState) {
        self.state = state
        updateState()
    }
    
    func changeStatus(_ status: SyncStatus) {
        self.status = status
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
            self.updateButtonState()
        }
    }
    
    init(status: SyncStatus) {
        self.status = status
        super.init(frame: .zero)
        setup()
    }
    
    private func setup() {
        backgroundView.backgroundColor = .black.withAlphaComponent(0.35)
        backgroundView.layer.cornerRadius = 7
        
        button.titleLabel?.font = AnytypeFont.caption1Regular.uiKitFont
        button.setImageAndTitleSpacing(6)
        button.showsMenuAsPrimaryAction = true
        
        updateButtonState()
        
        layoutUsing.anchors {
            $0.height.equal(to: 28)
            $0.centerY.equal(to: centerYAnchor)
        }
        
        addSubview(backgroundView) {
            $0.pinToSuperview()
        }
        
        addSubview(button) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 9, bottom: 0, right: -10))
        }
    }
    
    private func updateButtonState() {
        button.setImage(status.image, for: .normal)
        button.setImage(status.image, for: .highlighted)
        button.setImage(status.image, for: .selected)
        button.setTitle(status.title, for: .normal)
        button.menu = UIMenu(title: "", children: [ UIAction(title: status.description) { _ in } ] )
    }
    
    private func updateState() {
        backgroundView.alpha = state.backgroundAlpha
        button.setTitleColor(state.hiddableTextColor, for: .normal)
    }
    
    // MARK: - Unavailable
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
