import Combine
import UIKit


struct SimpleTableBlockContentConfiguration: BlockConfiguration {
    typealias View = SimpleTableBlockView

    @EquatableNoop private(set) var viewModelBuilder: () -> SimpleTableViewModel
    @EquatableNoop private(set) var blockDelegate: BlockDelegate
    @EquatableNoop private(set) var relativePositionProvider: RelativePositionProvider?
}

extension SimpleTableBlockContentConfiguration {
    var contentInsets: UIEdgeInsets {
        .init(top: 10, left: 0, bottom: -10, right: 0)
    }
}
