import UIKit
import Cache

final class MessageUIView: UIView, UIContentView {
    
    private struct CacheKey: Hashable {
        let data: MessageViewData
        let targetSize: CGSize
    }
    
    private struct CacheValue: Hashable {
        let iconFrame: CGRect?
        let bubbleFrame: CGRect?
        let size: CGSize
    }
    
    @MainActor
    private enum Cache {
        static var cache: MemoryStorage<CacheKey, CacheValue> = {
            let config = MemoryConfig(countLimit: 1000)
            return MemoryStorage<CacheKey, CacheValue>(config: config)
        }()
    }
    
    private lazy var iconView = IconViewUIKit()
    private lazy var bubbleView = MessageBubbleUIView()
//    private lazy var textView = MessageTextUIView()
//    private lazy var gridAttachments = MessageGridAttachmentUIViewContainer()
    
    private var sizeForCalculatedSize: CGSize = .zero
    private var calculatedSize: CGSize = .zero
    
    private var data: MessageViewData
    
    var configuration: any UIContentConfiguration {
        didSet {
            guard let configuration = configuration as? MessageConfiguration else { return }
            if data != configuration.model {
                data = configuration.model
                sizeForCalculatedSize = .zero
            }
        }
    }
    
    init(configuration: MessageConfiguration) {
        self.configuration = configuration
        self.data = configuration.model
        super.init(frame:.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let cacheValue = updateFramesIfNeeded(size: size)
        return cacheValue.size
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        let cacheValue = updateFramesIfNeeded(size: targetSize)
        return cacheValue.size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cacheValue = updateFramesIfNeeded(size: frame.size)
    
        if let bubbleFrame = cacheValue.bubbleFrame {
            bubbleView.messageText = NSAttributedString(data.messageString)
            bubbleView.isRight = data.position.isRight
            bubbleView.frame = bubbleFrame
            bubbleView.isHidden = false
        } else {
            bubbleView.isHidden = true
        }
        
        if let iconFrame = cacheValue.iconFrame {
            iconView.icon = data.authorIcon
            iconView.frame = iconFrame
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }
    
        
//        textView.text = messageText
//        textView.frame = cacheValue.textFrame
    }
    
    // MARK: - Private
    
    private func setupView() {
        addSubview(iconView)
        addSubview(bubbleView)
    }
    
    private func updateFramesIfNeeded(size: CGSize) -> CacheValue {
        let key = CacheKey(data: data, targetSize: size)
        
        if let cacheValue = try? Cache.cache.object(forKey: key) {
            return cacheValue
        }
        
        let containerInsets = UIEdgeInsets(top: 0, left: 14, bottom: data.nextSpacing.height, right: 14)
        let iconSide: CGFloat = 32
        let spacingBetweenIconAndText: CGFloat = 6
        let spacingForOtherSize: CGFloat = 26
        
        let showIcon: Bool
        let iconSize: CGSize?
        switch data.authorIconMode {
        case .show:
            iconSize = CGSize(width: iconSide, height: iconSide)
            showIcon = true
        case .empty:
            iconSize = CGSize(width: iconSide, height: iconSide)
            showIcon = false
        case .hidden:
            iconSize = nil
            showIcon = false
        }
        
        
        let iconWidth = iconSize.map { $0.width + spacingBetweenIconAndText } ?? 0
        let bubbleWidth = size.width - iconWidth - spacingForOtherSize - containerInsets.left - containerInsets.right
        
        var bubbleSize: CGSize?
        if !data.messageString.isEmpty {
            bubbleView.messageText = NSAttributedString(data.messageString)
            bubbleSize = bubbleView.sizeThatFits(
                CGSize(width: bubbleWidth, height: .greatestFiniteMagnitude)
            )
        }
        
        var iconFrame: CGRect?
        var bubbleFrame: CGRect?
        
        let size = CGSize(
            width: iconWidth + (bubbleSize?.width ?? 0) + spacingForOtherSize + containerInsets.left + containerInsets.right,
            height: (bubbleSize?.height ?? 0) + containerInsets.top + containerInsets.bottom
        )
        
        var freeContentFrame = CGRect(origin: .zero, size: size)
        freeContentFrame = freeContentFrame.inset(by: containerInsets)
        
        if data.position.isRight {
            if let iconSize {
                iconFrame = CGRect(
                    origin: CGPoint(x: freeContentFrame.maxX - iconSize.width, y: freeContentFrame.maxY - iconSize.height),
                    size: iconSize
                )
            }
            
            if let iconFrame {
                freeContentFrame = freeContentFrame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: iconFrame.width + spacingBetweenIconAndText))
            }
            
            if let bubbleSize {
                bubbleFrame = CGRect(
                    origin: CGPoint(x: freeContentFrame.maxX - bubbleSize.width, y: freeContentFrame.maxY - bubbleSize.height),
                    size: bubbleSize
                )
            }
            
        } else {
            
            if let iconSize {
                iconFrame = CGRect(
                    origin: CGPoint(x: freeContentFrame.minX, y: freeContentFrame.maxY - iconSize.height),
                    size: iconSize
                )
            }
            
            if let iconFrame {
                freeContentFrame = freeContentFrame.inset(by: UIEdgeInsets(top: 0, left: iconFrame.width + spacingBetweenIconAndText, bottom: 0, right: 0))
            }
            
            if let bubbleSize {
                bubbleFrame = CGRect(
                    origin: CGPoint(x: freeContentFrame.minX, y: freeContentFrame.minY),
                    size: bubbleSize
                )
            }
        }
        
        let cacheValue = CacheValue(iconFrame: showIcon ? iconFrame : nil, bubbleFrame: bubbleFrame, size: size)
        Cache.cache.setObject(cacheValue, forKey: key)
        
        if size != calculatedSize {
            let key = CacheKey(data: data, targetSize: calculatedSize)
            Cache.cache.setObject(cacheValue, forKey: key)
        }
        
        return cacheValue
    }
    
//    private func updateView(targetSize: CGSize) {
//        guard sizeForCalculatedSize != targetSize else { return }
//        sizeForCalculatedSize = targetSize
//        
//        let horizontalOuterPadding: CGFloat = 12
//        let padingBetweenTextAndIcon: CGFloat = 6
//        let iconSide: CGFloat = 32
//        
//        var height: CGFloat = 0
//        
//        var availableWidthForText: CGFloat = targetSize.width
//        
//        // Outer padding
//        availableWidthForText -= (horizontalOuterPadding * 2)
//        
//        // Icon
//        
//        switch data.authorIconMode {
//        case .show:
//            iconView.icon = data.authorIcon
//            iconView.frame.size = CGSize(width: iconSide, height: iconSide)
//            iconView.alpha = 1
//            availableWidthForText -= iconSide
//            availableWidthForText -= padingBetweenTextAndIcon
//        case .empty:
//            iconView.alpha = 0
//            availableWidthForText -= iconSide
//            availableWidthForText -= padingBetweenTextAndIcon
//        case .hidden:
//            iconView.alpha = 0
//            break
//        }
//        
//        // Min spacing from other Size
//        
//        availableWidthForText -= 26
//        availableWidthForText -= padingBetweenTextAndIcon
//        
        // Attachments
        
//        gridAttachments.objects = []
//        
//        if let objects = data.linkedObjects {
//            switch objects {
//            case .list:
//                break
//            case .grid(let items):
//                gridAttachments.objects = items
//                
//                let attachmentsSize = gridAttachments.sizeThatFits(
//                    CGSize(
//                        width: availableWidthForText,
//                        height: .greatestFiniteMagnitude
//                    )
//                )
//                
//                gridAttachments.frame.size = attachmentsSize
//                height += attachmentsSize.height
//            case .bookmark(let item):
//                break
//            }
//        }
        
        // Text Label
        
//        textView.text = NSAttributedString(data.messageString)
//        
//        let textSize = textView.sizeThatFits(CGSize(width: availableWidthForText, height: targetSize.height))
        
        // Calculate origins
        
//        height += textSize.height
//        height += data.nextSpacing.height
//        
//        if data.position.isRight {
//            
//            iconView.frame.origin = CGPoint(
//                x: targetSize.width - horizontalOuterPadding - iconSide,
//                y: height - data.nextSpacing.height - iconSide
//            )
//            
//            let contentX = iconView.frame.minX - padingBetweenTextAndIcon
//            
//            textView.frame.origin = CGPoint(
//                x: iconView.frame.minX - padingBetweenTextAndIcon,
//                y: height - textSize.height - data.nextSpacing.height
//            )
//            
//            gridAttachments.frame.origin = CGPoint(
//                x: contentX,
//                y: 0
//            )
//            
//        } else {
//            
//            iconView.frame.origin = CGPoint(
//                x: horizontalOuterPadding,
//                y: height - data.nextSpacing.height - iconSide
//            )
//            
//            let contentX = iconView.frame.maxX + padingBetweenTextAndIcon
//            
//            textView.frame.origin = CGPoint(
//                x: iconView.frame.maxX + padingBetweenTextAndIcon,
//                y: height - textSize.height - data.nextSpacing.height
//            )
//            
//            gridAttachments.frame.origin = CGPoint(
//                x: contentX,
//                y: 0
//            )
//        }
//        
//        calculatedSize = CGSize(width: targetSize.width, height: height)
//        
//        setNeedsLayout()
//    }
}
