import UIKit
import Combine

protocol SimpleTableBlockProtocol: HashableProvier {
    var heightDidChangedSubject: PassthroughSubject<Void, Never> { get }
}

struct SimpleTableCellConfiguration<Configuration: BlockConfiguration>: Hashable, SimpleTableBlockProtocol {
    let item: Configuration
    let backgroundColor: UIColor?

    @EquatableNoop var heightDidChangedSubject = PassthroughSubject<Void, Never>()

    var hashable: AnyHashable {
        [
            item.hashValue, backgroundColor.hashValue
        ].compactMap { $0 } as AnyHashable
    }

    init(
        item: Configuration,
        backgroundColor: UIColor?
    ) {
        self.item = item
        self.backgroundColor = backgroundColor
    }
}
