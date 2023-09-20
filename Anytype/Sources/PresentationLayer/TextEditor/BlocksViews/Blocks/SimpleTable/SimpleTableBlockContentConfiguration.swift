import UIKit
import Services

struct SimpleTableBlockContentConfiguration: BlockConfiguration {
    typealias View = SimpleTableBlockView

    let info: BlockInformation
    let dependenciesBuilder: SimpleTableDependenciesBuilder
    let onChangeHeight: () -> Void

    static func == (
        lhs: SimpleTableBlockContentConfiguration,
        rhs: SimpleTableBlockContentConfiguration
    ) -> Bool {
        lhs.info.id == rhs.info.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(info.id)
    }
}

extension SimpleTableBlockContentConfiguration {
    var contentInsets: UIEdgeInsets {
        .init(top: 10, left: 0, bottom: 10, right: 0)
    }
}
