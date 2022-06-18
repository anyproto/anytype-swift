import Combine
import UIKit


struct SimpleTableBlockContentConfiguration: BlockConfiguration {
    typealias View = SimpleTableBlockView

    let widths: [CGFloat]
    let items: [[SimpleTableBlockProtocol]]
    
    @EquatableNoop private(set) var blockDelegate: BlockDelegate
    @EquatableNoop private(set) var relativePositionProvider: RelativePositionProvider?

    static func == (
        lhs: SimpleTableBlockContentConfiguration,
        rhs: SimpleTableBlockContentConfiguration
    ) -> Bool {
        lhs.items.hashable == rhs.items.hashable &&
        lhs.widths == rhs.widths
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(items.hashable)
        hasher.combine(widths)
    }
}

extension Array where Element == [SimpleTableBlockProtocol] {
    var hashable: AnyHashable {
        map { sections -> AnyHashable in
            return sections.map { $0.hashable }
        }

    }
}

extension SimpleTableBlockContentConfiguration {
    var contentInsets: UIEdgeInsets {
        .init(top: 10, left: 0, bottom: -10, right: 0)
    }
}
