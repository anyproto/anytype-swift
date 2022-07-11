import Combine
import UIKit
import BlocksModels


struct SimpleTableBlockContentConfiguration: BlockConfiguration {
    typealias View = SimpleTableBlockView

    let blockId: BlockId
    let stateManager: SimpleTableStateManager
    weak var blockDelegate: BlockDelegate?
    weak var relativePositionProvider: RelativePositionProvider?

    let viewModelBuilder: () -> SimpleTableViewModel

    static func == (
        lhs: SimpleTableBlockContentConfiguration,
        rhs: SimpleTableBlockContentConfiguration
    ) -> Bool {
        lhs.blockId == rhs.blockId
    }

    func hash(into hasher: inout Hasher) {}
}

extension SimpleTableBlockContentConfiguration {
    var contentInsets: UIEdgeInsets {
        .init(top: 10, left: 0, bottom: -10, right: 0)
    }
}
