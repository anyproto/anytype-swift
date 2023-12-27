import UIKit
import Services

extension BlockLinkState {
    var titleText: String {
        if deleted {
            return Loc.Object.Deleted.placeholder
        }

        return !title.isEmpty ? title : Loc.Object.Title.placeholder
    }

    var titleColor: UIColor {
        if case let .object(.todo(value)) = icon, value {
            return .Button.active
        }

        if deleted || archived {
            return .Button.active
        }
        
        return .Text.primary
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
