import UIKit
import Services
import Loc

final class EditorWebBannerItem: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        
        let attributedString = NSMutableAttributedString()
        
        let liveOnWebAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.caption1Regular,
            .foregroundColor: UIColor.Text.primary
        ]
        attributedString.append(NSAttributedString(string: Loc.Publishing.WebBanner.liveOnWeb + " ", attributes: liveOnWebAttributes))
        
        let viewSiteAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.caption1Semibold,
            .foregroundColor: UIColor.Text.primary
        ]
        attributedString.append(NSAttributedString(string: Loc.Publishing.WebBanner.viewSite, attributes: viewSiteAttributes))
        
        label.attributedText = attributedString
        label.textAlignment = .center
        return label
    }()
    
    private let backgroundView = UIView()
    
    private var itemState: EditorBarItemState?
    private var heightConstraint: NSLayoutConstraint?
    
    private let onTap: () -> ()
    
    func changeItemState(_ itemState: EditorBarItemState) {
        self.itemState = itemState
        updateBackgroundColor()
    }
    
    func setVisible(_ visible: Bool) {
        isHidden = !visible
        heightConstraint?.constant = visible ? 40 : 0
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
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 40)
        heightConstraint?.isActive = true
        
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
            updateLabelTextColor(.Text.primary)
            return
        }
        
        backgroundView.backgroundColor = .black.withAlphaComponent(0.35)
        backgroundView.alpha = itemState.backgroundAlpha
        updateLabelTextColor(itemState.buttonTextColor)
    }
    
    private func updateLabelTextColor(_ color: UIColor) {
        guard let attributedText = label.attributedText else { return }
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: attributedText.length))
        label.attributedText = mutableAttributedString
    }
    
    // MARK: - Unavailable
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
