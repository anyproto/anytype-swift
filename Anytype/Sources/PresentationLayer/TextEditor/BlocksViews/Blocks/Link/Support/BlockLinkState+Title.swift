import UIKit

extension BlockLinkState {
    
    var attributedTitle: NSAttributedString {
        if deleted {
            return NSAttributedString(
                string: "Non-existent object".localized,
                attributes: disabledAttributes
            )
        }
        
        return NSAttributedString(
            string: !title.isEmpty ? title : "Untitled".localized,
            attributes: archived ? disabledAttributes : enabledAttributes
        )
    }
    
    private var disabledAttributes: [NSAttributedString.Key : Any] {
        [
            .font: UIFont.bodyRegular,
            .foregroundColor: UIColor.buttonActive,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.buttonInactive
        ]
    }
    
    private var enabledAttributes: [NSAttributedString.Key : Any] {
        [
            .font: UIFont.bodyRegular,
            .foregroundColor: UIColor.textPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.buttonActive
        ]
    }
    
}
