import UIKit

struct MediaFileScreenData: Hashable, Sendable {
    let items: [PreviewRemoteItem]
    let startAtIndex: Int
    let sourceView: UIView?
    
    init(items: [PreviewRemoteItem], startAtIndex: Int = 0, sourceView: UIView? = nil) {
        self.items = items
        self.startAtIndex = startAtIndex
        self.sourceView = sourceView
    }
    
    var spaceId: String {
        items.first?.fileDetails.spaceId ?? ""
    }
}
