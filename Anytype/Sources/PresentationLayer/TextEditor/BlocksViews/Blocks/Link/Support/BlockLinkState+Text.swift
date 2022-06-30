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
        
        return NSAttributedString(
            string: !title.isEmpty ? title : "Untitled".localized,
            attributes: archived ? disabledAttributes : enabledAttributes
        )
    }

    var attributedDescription: NSAttributedString {
        guard !deleted, descriptionState.hasDescription, description.isNotEmpty else {
            return NSAttributedString(string: .empty)
        }

        return NSAttributedString(
            string: description,
            attributes: archived ? disabledDescriptionAttributes : enabledDescriptionAttributes
        )
    }

    var attributedType: NSAttributedString {
        guard !deleted, let type = type else {
            return NSAttributedString(string: .empty)
        }

        return NSAttributedString(
            string: type.name,
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
        let underlineStyle: NSUnderlineStyle = cardStyle == .card ? [] : .single

        return [
            .font: UIFont.bodyRegular,
            .foregroundColor: UIColor.textPrimary,
            .underlineStyle: underlineStyle.rawValue ,
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
