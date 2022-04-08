import UIKit

protocol BlockContentView where Self: UIView {
    associatedtype Configuration: BlockConfiguration

    func update(with configuration: Configuration)

    // Optional
    func update(with state: UICellConfigurationState)
}

extension BlockContentView {
    func update(with state: UICellConfigurationState) {}
}
