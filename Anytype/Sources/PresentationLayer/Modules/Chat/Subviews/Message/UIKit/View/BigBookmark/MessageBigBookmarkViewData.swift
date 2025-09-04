import UIKit
import Services

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
        self.objectId = details.id
        self.host = NSAttributedString(
            string: details.source?.url.host() ?? "",
            attributes: [.font: UIFont.relation3Regular]
        )
        self.title = NSAttributedString(
            string: details.name,
            attributes: [.font: UIFont.previewTitle2Medium]
        )
        self.description = NSAttributedString(
            string: details.name,
            attributes: [.font: UIFont.relation3Regular]
        )
        self.pictureId = details.picture
        self.position = position
    }
}
