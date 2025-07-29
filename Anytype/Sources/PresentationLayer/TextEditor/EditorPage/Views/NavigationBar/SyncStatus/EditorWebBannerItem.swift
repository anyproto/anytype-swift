import UIKit
import Services

final class EditorWebBannerItem: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        
        label.text = "This object is live on the web. View site ↗︎"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        
        label.textColor = .Text.primary
        label.textAlignment = .center
        return label
    }()
    
    private let backgroundView = UIView()
    
    private var itemState: EditorBarItemState?
    private var isVisible: Bool = false
    
    private let onTap: () -> ()
    
    func changeItemState(_ itemState: EditorBarItemState) {
        self.itemState = itemState
        updateBackgroundColor()
    }
    
    func setVisible(_ visible: Bool) {
        self.isVisible = visible
        self.isHidden = !visible
        
        heightAnchor.constraint(equalToConstant: visible ? 40 : 0).isActive = true
    }
    
    init(onTap: @escaping () -> ()) {
        self.onTap = onTap
        super.init(frame: .zero)
        setup()
    }
    
    // MARK: - Private
    
    private func setup() {
        updateBackgroundColor()
        
        backgroundView.layer.cornerRadius = 8
        backgroundView.backgroundColor = .Control.secondary
        
        addSubview(backgroundView) { $0.pinToSuperview() }
        addSubview(label) { 
            $0.pinToSuperview(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        setVisible(false)
    }
    
    @objc private func handleTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        onTap()
    }
    
    private func updateBackgroundColor() {
        guard let itemState = itemState else {
            backgroundView.backgroundColor = .clear
            backgroundView.alpha = 0
            label.textColor = .Text.primary
            return
        }
        
        backgroundView.backgroundColor = .black.withAlphaComponent(0.35)
        backgroundView.alpha = itemState.backgroundAlpha
        label.textColor = itemState.buttonTextColor
    }
    
    // MARK: - Unavailable
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
