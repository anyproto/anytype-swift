import BlocksModels
import UIKit

struct DataViewBlockContent: Hashable {
    let title: String?
    let iconImage: ObjectIconImage?
    let badgeTitle: String?
}

struct DataViewBlockConfiguration: BlockConfiguration {
    typealias View = DataViewBlockView

    let content: DataViewBlockContent
}
