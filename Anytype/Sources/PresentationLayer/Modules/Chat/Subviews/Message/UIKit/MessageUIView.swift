import UIKit

final class MessageUIView: UIView, UIContentView {
    
    private lazy var iconView = IconViewUIKit()
    private lazy var textView = MessageTextUIView()
    private lazy var gridAttachments = MessageGridAttachmentUIViewContainer()
    
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
        updateView(targetSize: size)
        return calculatedSize
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        updateView(targetSize: targetSize)
        return calculatedSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateView(targetSize: frame.size)
    }
    
    // MARK: - Private
    
    private func setupView() {
        addSubview(iconView)
        addSubview(textView)
        addSubview(gridAttachments)
    }
    
    private func updateView(targetSize: CGSize) {
        guard sizeForCalculatedSize != targetSize else { return }
        sizeForCalculatedSize = targetSize
        
        let horizontalOuterPadding: CGFloat = 12
        let padingBetweenTextAndIcon: CGFloat = 6
        let iconSide: CGFloat = 32
        
        var height: CGFloat = 0
        
        var availableWidthForText: CGFloat = targetSize.width
        
        // Outer padding
        availableWidthForText -= (horizontalOuterPadding * 2)
        
        // Icon
        
        switch data.authorIconMode {
        case .show:
            iconView.icon = data.authorIcon
            iconView.frame.size = CGSize(width: iconSide, height: iconSide)
            iconView.alpha = 1
            availableWidthForText -= iconSide
            availableWidthForText -= padingBetweenTextAndIcon
        case .empty:
            iconView.alpha = 0
            availableWidthForText -= iconSide
            availableWidthForText -= padingBetweenTextAndIcon
        case .hidden:
            iconView.alpha = 0
            break
        }
        
        // Min spacing from other Size
        
        availableWidthForText -= 26
        availableWidthForText -= padingBetweenTextAndIcon
        
        // Attachments
        
        gridAttachments.objects = []
        
        if let objects = data.linkedObjects {
            switch objects {
            case .list:
                break
            case .grid(let items):
                gridAttachments.objects = items
                
                let attachmentsSize = gridAttachments.sizeThatFits(
                    CGSize(
                        width: availableWidthForText,
                        height: .greatestFiniteMagnitude
                    )
                )
                
                gridAttachments.frame.size = attachmentsSize
                height += attachmentsSize.height
            case .bookmark(let item):
                break
            }
        }
        
        // Text Label
        
        textView.text = NSAttributedString(data.messageString)
        
        let textSize = textView.sizeThatFits(CGSize(width: availableWidthForText, height: targetSize.height))
        
        // Calculate origins
        
        height += textSize.height
        height += data.nextSpacing.height
        
        if data.position.isRight {
            
            iconView.frame.origin = CGPoint(
                x: targetSize.width - horizontalOuterPadding - iconSide,
                y: height - data.nextSpacing.height - iconSide
            )
            
            let contentX = iconView.frame.minX - padingBetweenTextAndIcon
            
            textView.frame.origin = CGPoint(
                x: iconView.frame.minX - padingBetweenTextAndIcon,
                y: height - textSize.height - data.nextSpacing.height
            )
            
            gridAttachments.frame.origin = CGPoint(
                x: contentX,
                y: 0
            )
            
        } else {
            
            iconView.frame.origin = CGPoint(
                x: horizontalOuterPadding,
                y: height - data.nextSpacing.height - iconSide
            )
            
            let contentX = iconView.frame.maxX + padingBetweenTextAndIcon
            
            textView.frame.origin = CGPoint(
                x: iconView.frame.maxX + padingBetweenTextAndIcon,
                y: height - textSize.height - data.nextSpacing.height
            )
            
            gridAttachments.frame.origin = CGPoint(
                x: contentX,
                y: 0
            )
        }
        
        calculatedSize = CGSize(width: targetSize.width, height: height)
        
        setNeedsLayout()
    }
}
