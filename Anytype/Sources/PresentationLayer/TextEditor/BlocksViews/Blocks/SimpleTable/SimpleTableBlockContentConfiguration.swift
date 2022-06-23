import Combine
import UIKit


struct SimpleTableBlockContentConfiguration: BlockConfiguration {
    typealias View = SimpleTableBlockView

    weak var blockDelegate: BlockDelegate?
    let viewModelBuilder: () -> SimpleTableViewModel
    let relativePositionProvider: RelativePositionProvider?

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
