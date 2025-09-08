import UIKit

public extension NSAttributedString.Key {
    static let tapHandler = NSAttributedString.Key("TapHandler")
}

public final class TappableLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        
        addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard let characterIndex = gesture.characterIndexTappedInLabel(self) else {
            return
        }
        
        guard let characterAttribute = self.attributedText?.attributes(
            at: characterIndex,
            effectiveRange: nil
        ) else {
            return
        }
        
        if let tapHandler = characterAttribute[.tapHandler] as? (() -> Void) {
            tapHandler()
        }
    }
}

private extension UITapGestureRecognizer {

    func characterIndexTappedInLabel(_ label: UILabel) -> Int? {
        guard let attributedText = label.attributedText else {
            return nil
        }
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        
        let locationOfTouchInLabel = location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )

        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        let indexOfCharacter = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        return indexOfCharacter
    }
}
