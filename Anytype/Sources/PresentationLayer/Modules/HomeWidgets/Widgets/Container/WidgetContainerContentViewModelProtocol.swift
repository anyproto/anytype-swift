import Foundation
import Combine

@MainActor
protocol WidgetContainerContentViewModelProtocol: AnyObject, ObservableObject {
    var name: String { get }
    var icon: ImageAsset? { get }
    var dragId: String? { get }
    var menuItems: [WidgetMenuItem] { get }
    var allowContent: Bool { get }
    var allowCreateObject: Bool { get }
    
    func startHeaderSubscription()
    func stopHeaderSubscription()
    func startContentSubscription()
    func stopContentSubscription()
    func onHeaderTap()
    func onCreateObjectTap()
}

// Default Implementation

extension WidgetContainerContentViewModelProtocol {
    var icon: ImageAsset? { nil }
    var menuItems: [WidgetMenuItem] { [.addBelow, .changeSource, .changeType, .remove] }
    var allowContent: Bool { true }
    var allowCreateObject: Bool { false }
    func onCreateObjectTap() {}
}
