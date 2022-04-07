import UIKit
import BlocksModels

extension BlockLinkState {
    
    var attributedTitle: NSAttributedString {
        if deleted {
            return NSAttributedString(
                string: "Non-existent object".localized,
                attributes: disabledAttributes
            )
        }

        guard objectPreviewFields.withName else {
            return NSAttributedString(string: .empty)
        }
        
        return NSAttributedString(
            string: !title.isEmpty ? title : "Untitled".localized,
            attributes: archived ? disabledAttributes : enabledAttributes
        )
    }

    var attributedDescription: NSAttributedString {
        guard !deleted, hasDescription else {
            return NSAttributedString(string: .empty)
        }

        return NSAttributedString(
            string: description,
            attributes: archived ? disabledDescriptionAttributes : enabledDescriptionAttributes
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

    private var disabledDescriptionAttributes: [NSAttributedString.Key : Any] {
        [
            .font: UIFont.relation2Regular,
            .foregroundColor: UIColor.textSecondary,
        ]
    }

    private var enabledDescriptionAttributes: [NSAttributedString.Key : Any] {
        [
            .font: UIFont.relation2Regular,
            .foregroundColor: UIColor.textSecondary,
        ]
    }
    
}
