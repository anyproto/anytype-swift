import BlocksModels
import UIKit

struct DataViewBlockConfiguration: BlockConfiguration {
    typealias View = DataViewBlockView

    let title: String
    let iconImage: ObjectIconImage?
}
