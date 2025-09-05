import Foundation
import StoredHashMacro
import UIKit

@StoredHash
struct MessageTextViewData: Equatable, Hashable {
    let message: NSAttributedString
    let infoText: NSAttributedString
    let synced: Bool?
    let position: MessageHorizontalPosition
    
    static let infoLineLimit = 1
}

extension MessageTextViewData {
    init(
        message: NSAttributedString,
        infoText: String,
        synced: Bool?,
        position: MessageHorizontalPosition
    ) {
        self.init(
            message: message,
            infoText: NSAttributedString(
                string: infoText,
                attributes: [.font: UIFont.caption2Regular]
            ),
            synced: synced,
            position: position
        )
    }
}
