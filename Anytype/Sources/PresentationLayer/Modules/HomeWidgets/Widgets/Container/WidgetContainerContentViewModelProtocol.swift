import Foundation
import Combine

@MainActor
protocol WidgetContainerContentViewModelProtocol: AnyObject, ObservableObject {
    var name: String { get }
    var icon: ImageAsset? { get }
    var menuItems: [WidgetMenuItem] { get }
    var allowContent: Bool { get }
    
    func onAppear()
    func onDisappear()
    func onHeaderTap()
}

// Default Implementation

extension WidgetContainerContentViewModelProtocol {
    var icon: ImageAsset? { nil }
    var menuItems: [WidgetMenuItem] { [.changeSource, .changeType, .remove] }
    var allowContent: Bool { true }
}
