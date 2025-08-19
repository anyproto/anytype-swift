import UIKit
import Cache

final class MessageTextUIView: UIView {
    
    private struct CacheKey: Hashable {
        let messageText: NSAttributedString?
        let infoText: String?
        let targetSize: CGSize
    }
    
    private struct CacheValue: Hashable {
        let textFrame: CGRect
        let size: CGSize
    }
    
    @MainActor
    private enum Cache {
        static var cache: MemoryStorage<CacheKey, CacheValue> = {
            let config = MemoryConfig(countLimit: 1000)
            return MemoryStorage<CacheKey, CacheValue>(config: config)
        }()
    }
    
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
    
    var messageText: NSAttributedString? {
        didSet {
            if messageText != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var infoText: String? {
        didSet {
            if infoText != oldValue {
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
        let cacheValue = updateFramesIfNeeded(size: frame.size)
        
        textLabel.attributedText = messageText
        textLabel.frame = cacheValue.textFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let cacheValue = updateFramesIfNeeded(size: size)
        return cacheValue.size
    }
    
    // MARK: - Private
    
    private func setupLayout() {
        addSubview(textLabel)
    }
    
    private func updateFramesIfNeeded(size: CGSize) -> CacheValue {
        let key = CacheKey(text: text, targetSize: size)
        
        let width = size.width
        
        if let cacheValue = try? Cache.cache.object(forKey: key) {
            return cacheValue
        }
        
        let textIsEmpty = text?.string.isEmpty ?? true
        var textSize: CGSize = .zero
        if !textIsEmpty {
            textLabel.attributedText = text
            textSize = textLabel.sizeThatFits(
                CGSize(
                    width: width,
                    height: .greatestFiniteMagnitude
                )
            )
        }
        
        let textFrame = CGRect(
            origin: .zero,
            size: textSize
        )
        
        let calculatedSize = CGSize(width: textFrame.width, height: textFrame.height + 4 * 2)
        
        let cacheValue = CacheValue(
            textFrame: textFrame,
            size: calculatedSize
        )
        
        Cache.cache.setObject(cacheValue, forKey: key)
        
        if size != calculatedSize {
            let key = CacheKey(text: text, targetSize: calculatedSize)
            Cache.cache.setObject(cacheValue, forKey: key)
        }
        
        return cacheValue
    }
}
