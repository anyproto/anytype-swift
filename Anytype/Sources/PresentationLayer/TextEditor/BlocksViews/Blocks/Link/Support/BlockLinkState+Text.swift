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
            return .Button.active
        }

        if deleted || archived {
            return .Button.active
        }



        return .TextNew.primary
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
                .foregroundColor: UIColor.TextNew.secondary,
            ]
        )
    }
    
    private var disabledAttributes: [NSAttributedString.Key : Any] {
        [
            .font: UIFont.bodyRegular,
            .foregroundColor: UIColor.Button.active
        ]
    }
    
    private var enabledAttributes: [NSAttributedString.Key : Any] {

        return [
            .font: UIFont.bodyRegular,
            .foregroundColor: UIColor.TextNew.primary
        ]
    }

    private var disabledDescriptionAttributes: [NSAttributedString.Key : Any] {
        [
            .font: UIFont.relation2Regular,
            .foregroundColor: UIColor.TextNew.secondary,
        ]
    }

    private var enabledDescriptionAttributes: [NSAttributedString.Key : Any] {
        [
            .font: UIFont.relation2Regular,
            .foregroundColor: UIColor.TextNew.primary,
        ]
    }
    
}
