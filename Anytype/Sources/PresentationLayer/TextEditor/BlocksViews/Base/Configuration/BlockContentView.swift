import UIKit

protocol ReusableContent {
    static var reusableIdentifier: String { get }
}

protocol BlockContentView: ReusableContent where Self: UIView {
    associatedtype Configuration: BlockConfiguration

    func update(with configuration: Configuration)

    // Optional
    func update(with state: UICellConfigurationState)
}

extension BlockContentView {
    static var reusableIdentifier: String { String(describing: Self.self) }
}

extension BlockContentView {
    func update(with state: UICellConfigurationState) {}
}

