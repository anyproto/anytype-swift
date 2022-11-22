import UIKit
import BlocksModels

extension BlockLinkState {
    var titleText: String {
        if deleted {
            return Loc.deletedObject
        }

        return !title.isEmpty ? title : Loc.untitled
    }

    var textTitleFont: AnytypeFont { .previewTitle1Medium }
    var cardTitleFont: AnytypeFont { .uxTitle2Medium }

    var titleColor: UIColor {
        if case let .checkmark(value) = style, value {
            return .buttonActive
        }

        if deleted || archived {
            return .buttonActive
        }



        return .textPrimary
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
            .foregroundColor: UIColor.buttonActive
        ]
    }
    
    private var enabledAttributes: [NSAttributedString.Key : Any] {

        return [
            .font: UIFont.bodyRegular,
            .foregroundColor: UIColor.textPrimary
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
