import Combine
import UIKit


struct SimpleTableBlockContentConfiguration: BlockConfiguration {
    typealias View = SimpleTableBlockView

    let widths: [CGFloat]

    @EquatableNoop private(set) var items: [[SimpleTableBlockProtocol]]
    @EquatableNoop private(set) var relativePositionProvider: RelativePositionProvider?
    @EquatableNoop private(set) var resetPublisher: AnyPublisher<Void, Never>
    @EquatableNoop private(set) var heightDidChanged: () -> Void
}

extension SimpleTableBlockContentConfiguration {
    var contentInsets: UIEdgeInsets {
        .init(top: 10, left: 0, bottom: -10, right: 0)
    }
}
