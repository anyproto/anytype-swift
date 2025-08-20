import UIKit
import Cache

final class MessageTextUIView: UIView {
    
    // MARK: - Private properties
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Public properties
    
    var text: NSAttributedString? {
        didSet { textLabel.attributedText = text }
    }
    
    var layout: MessageTextLayout? {
        didSet {
            if layout != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    // MARK: - Pulic
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout else { return }
        textLabel.frame = layout.textFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layout?.size ?? .zero
    }
    
    // MARK: - Private
    
    private func setupLayout() {
        addSubview(textLabel)
    }
}
