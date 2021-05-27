import UIKit

final class DocumentIconEmojiView: UIView {
    
    // MARK: - Private properties
    
    private let emojiLabel: UILabel = UILabel()
        
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }

}

// MARK: - ConfigurableView

extension DocumentIconEmojiView: ConfigurableView {
    
    func configure(model: IconEmoji) {
        emojiLabel.text = model.value
    }
    
}

// MARK: - Private extension

private extension DocumentIconEmojiView {
    
    func setupView() {
        backgroundColor = .grayscale10
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius
        
        configureEmojiLabel()
        
        setUpLayout()
    }
    
    func configureEmojiLabel() {
        emojiLabel.backgroundColor = .grayscale10
        emojiLabel.font = .systemFont(ofSize: 64) // Used only for emoji
        emojiLabel.textAlignment = .center
        emojiLabel.adjustsFontSizeToFitWidth = true
        emojiLabel.isUserInteractionEnabled = false
    }
    
    func setUpLayout() {
        addSubview(emojiLabel)
        emojiLabel.pinAllEdges(to: self)
    }
    
}

// MARK: - Constants

private extension DocumentIconEmojiView {
    
    enum Constants {
        static let cornerRadius: CGFloat = 20
    }
    
}
