import Foundation
import UIKit
import Combine

enum PageCellIcon {
    case emoji(String)
    case imageId(String)
}

struct PageCellData: Identifiable {
    let id: String
    var destinationId: String
    var icon: PageCellIcon?
    var title: String
    var type: String
}
