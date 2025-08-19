import UIKit
import Cache

final class MessageBubbleUIView: UIView {
    
    private struct CacheKey: Hashable {
        let messageText: NSAttributedString?
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
    
    private lazy var textView = MessageTextUIView()
    private lazy var gridAttachments = MessageGridAttachmentUIViewContainer()
    
    // MARK: - Public properties
    
    var messageText: NSAttributedString? {
        didSet {
            if messageText != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var isRight: Bool = false {
        didSet { updateBackgroundColor() }
    }
    
    var messageYourBackgroundColor: UIColor = .white {
        didSet { updateBackgroundColor() }
    }
    
    // MARK: - Pulic
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cacheValue = updateFramesIfNeeded(size: frame.size)
        
        let textIsEmpty = messageText?.string.isEmpty ?? true
        if textIsEmpty {
            textView.removeFromSuperview()
        } else {
            textView.text = messageText
            textView.frame = cacheValue.textFrame
            addSubview(textView)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let cacheValue = updateFramesIfNeeded(size: size)
        return cacheValue.size
    }
    
    // MARK: - Private
    
    private func updateFramesIfNeeded(size: CGSize) -> CacheValue {
        let key = CacheKey(messageText: messageText, targetSize: size)
        
        if let cacheValue = try? Cache.cache.object(forKey: key) {
            return cacheValue
        }
        
        let width = size.width
//        let minimumHeight: CGFloat = 32
        let textInset = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        
        let textIsEmpty = messageText?.string.isEmpty ?? true
        var textSize: CGSize = .zero
        if !textIsEmpty {
            textView.text = messageText
            textSize = textView.sizeThatFits(
                CGSize(
                    width: width - textInset.left - textInset.right,
                    height: .greatestFiniteMagnitude
                )
            )
        }
        
        var textFrame = CGRect(
            origin: CGPoint(x: textInset.left, y: textInset.top),
            size: textSize
        )
        
        var textContainerSize = textFrame.inset(by: textInset.inverted).size
        
        // TODO: Cheh after apply normal text style
//        if textContainerSize.height < minimumHeight {
//            let offset = (minimumHeight - textContainerSize.height) * 0.5
//            textContainerSize.height = minimumHeight
//            textFrame.origin.y += offset
//        }
        
        let calculatedSize = CGSize(width: textContainerSize.width, height: textContainerSize.height)
        
        let cacheValue = CacheValue(
            textFrame: textFrame,
            size: calculatedSize
        )
        
        Cache.cache.setObject(cacheValue, forKey: key)
        
        if size != calculatedSize {
            let key = CacheKey(messageText: messageText, targetSize: calculatedSize)
            Cache.cache.setObject(cacheValue, forKey: key)
        }
        
        return cacheValue
    }

    private func updateBackgroundColor() {
        backgroundColor = isRight ? messageYourBackgroundColor : .Background.Chat.bubbleSomeones
    }
}
