import UIKit
import Services

struct MediaFileScreenData: Hashable, Sendable {
    let items: [PreviewRemoteItem]
    let startAtIndex: Int
    let sourceView: UIView?
    let route: MediaFileScreenRoute?
    
    init(items: [PreviewRemoteItem], startAtIndex: Int = 0, sourceView: UIView? = nil, route: MediaFileScreenRoute? = nil) {
        self.items = items
        self.startAtIndex = startAtIndex
        self.sourceView = sourceView
        self.route = route
    }
    
    var spaceId: String {
        items.first?.fileDetails.spaceId ?? ""
    }
}

extension MediaFileScreenData {
    init(selectedItem: ObjectDetails, allItems: [ObjectDetails], sourceView: UIView? = nil, route: MediaFileScreenRoute? = nil) {
        let items = allItems.compactMap { $0.previewRemoteItem }
        let startAtIndex = items.firstIndex { $0.id == selectedItem.id } ?? 0
        self.items = items
        self.startAtIndex = startAtIndex
        self.sourceView = sourceView
        self.route = route
    }
}
