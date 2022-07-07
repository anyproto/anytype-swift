import Combine
import UIKit


struct SimpleTableBlockContentConfiguration: BlockConfiguration {
    typealias View = SimpleTableBlockView

    var stateManager: EditorPageBlocksStateManagerProtocol
    weak var blockDelegate: BlockDelegate?
    weak var relativePositionProvider: RelativePositionProvider?

    let viewModelBuilder: () -> SimpleTableViewModel

    static func == (
        lhs: SimpleTableBlockContentConfiguration,
        rhs: SimpleTableBlockContentConfiguration
    ) -> Bool {
        return false
    }

    func hash(into hasher: inout Hasher) {}
}

extension SimpleTableBlockContentConfiguration {
    var contentInsets: UIEdgeInsets {
        .init(top: 10, left: 0, bottom: -10, right: 0)
    }
}
