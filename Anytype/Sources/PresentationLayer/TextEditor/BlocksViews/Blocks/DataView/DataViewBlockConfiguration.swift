import BlocksModels
import UIKit

enum DataViewBlockContent: Hashable {
    case data(title: String, iconImage: ObjectIconImage?)
    case noDataSource
}

struct DataViewBlockConfiguration: BlockConfiguration {
    typealias View = DataViewBlockView

    let content: DataViewBlockContent
}
