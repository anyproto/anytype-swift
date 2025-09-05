import UIKit
import Services
import StoredHashMacro

@StoredHash
struct MessageBigBookmarkViewData: Equatable, Hashable {
    let objectId: String
    let host: NSAttributedString
    let title: NSAttributedString
    let description: NSAttributedString
    let pictureId: String
    let position: MessageHorizontalPosition
    
    let hostLineLimit = 1
    let titleLineLimit = 1
    let descriptionLineLimit = 2
}

extension MessageBigBookmarkViewData {
    init(details: ObjectDetails, position: MessageHorizontalPosition) {
        self.init(
            objectId: details.id,
            host: NSAttributedString(
                string: details.source?.url.host() ?? "",
                attributes: [.font: UIFont.relation3Regular]
            ),
            title: NSAttributedString(
                string: details.name,
                attributes: [.font: UIFont.previewTitle2Medium]
            ),
            description: NSAttributedString(
                string: details.name,
                attributes: [.font: UIFont.relation3Regular]
            ),
            pictureId: details.picture,
            position: position
        )
    }
}
