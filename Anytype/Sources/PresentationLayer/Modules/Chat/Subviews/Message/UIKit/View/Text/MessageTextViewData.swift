import Foundation
import StoredHashMacro
import UIKit

@StoredHash
struct MessageTextViewData: Equatable, Hashable {
    let message: NSAttributedString
    let infoText: NSAttributedString
    let synced: Bool?
    
    static let infoLineLimit = 1
}

extension MessageTextViewData {
    init(
        message: NSAttributedString,
        infoText: String,
        synced: Bool?
    ) {
        self.init(
            message: message,
            infoText: NSAttributedString(
                string: infoText,
                attributes: [.font: UIFont.caption2Regular]
            ),
            synced: synced
        )
    }
}
