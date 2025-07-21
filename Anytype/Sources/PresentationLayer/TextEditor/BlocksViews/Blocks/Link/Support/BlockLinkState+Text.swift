import UIKit
import Services

extension BlockLinkState {
    var titleText: String {
        if deleted {
            return Loc.Object.Deleted.placeholder
        }

        return title.withPlaceholder
    }

    var titleColor: UIColor {
        if case let .object(.todo(value, _)) = icon, value {
            return .Control.secondary
        }

        if deleted || archived {
            return .Control.secondary
        }
        
        return .Text.primary
    }

    var attributedDescription: NSAttributedString {
        guard !deleted, descriptionState.hasDescription, description.isNotEmpty else {
            return NSAttributedString(string: "")
        }

        return NSAttributedString(
            string: description,
            attributes: archived ? disabledDescriptionAttributes : enabledDescriptionAttributes
        )
    }

    var attributedType: NSAttributedString {
        guard !deleted, let type = type else {
            return NSAttributedString(string: "")
        }

        return NSAttributedString(
            string: type.displayName,
            attributes: [
                .font: UIFont.relation2Regular,
                .foregroundColor: UIColor.Text.secondary,
            ]
        )
    }

    private var disabledDescriptionAttributes: [NSAttributedString.Key : Any] {
        [
            .font: UIFont.relation2Regular,
            .foregroundColor: UIColor.Text.secondary,
        ]
    }

    private var enabledDescriptionAttributes: [NSAttributedString.Key : Any] {
        [
            .font: UIFont.relation2Regular,
            .foregroundColor: UIColor.Text.primary,
        ]
    }
    
}
