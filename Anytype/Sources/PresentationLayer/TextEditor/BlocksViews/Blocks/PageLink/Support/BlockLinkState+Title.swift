import UIKit

extension BlockLinkState {
    var attributedTitle: NSAttributedString {
        if deleted {
            return NSAttributedString(
                string: "Non-existent object".localized,
                attributes: [
                    .font: UIFont.bodyRegular,
                    .foregroundColor: UIColor.textTertiary
                ]
            )
        }
        
        return NSAttributedString(
            string: !title.isEmpty ? title : "Untitled".localized,
            attributes: [
                .font: UIFont.bodyRegular,
                .foregroundColor: UIColor.textPrimary,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.textSecondary
            ]
        )
    }
}
