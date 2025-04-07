import UIKit

protocol DynamicHeightView: AnyObject {
    var heightDidChanged: (() -> Void)? { get set }
}

protocol ReusableContent {
    static var reusableIdentifier: String { get }
}

protocol FirstResponder: AnyObject {
    var isFirstResponderValueChangeHandler: ((Bool) -> Void)? { get set }
}

@MainActor
protocol BlockContentView: ReusableContent where Self: UIView {
    associatedtype Configuration: BlockConfiguration

    func update(with configuration: Configuration)

    // Optional
    func update(with state: UICellConfigurationState)
}

extension BlockContentView {
    func update(with state: UICellConfigurationState) {}
}

extension ReusableContent {
    static var reusableIdentifier: String { String(describing: Self.self) }
}
