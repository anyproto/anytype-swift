import UIKit

protocol BlockContentView: DynamicHeightView {
    associatedtype Configuration: BlockConfiguration

    static var reusableIdentifier: String { get }

    func update(with configuration: Configuration)

    // Optional
    func update(with state: UICellConfigurationState)
}

protocol DynamicHeightView where Self: UIView {
    var onHeightDidChange: (() -> Void)? { get set }
}

extension BlockContentView {
    static var reusableIdentifier: String { String(describing: Self.self) }

    var onHeightDidChange: (() -> Void)? { get { nil } set {} }
}

extension BlockContentView {
    func update(with state: UICellConfigurationState) {}
}

