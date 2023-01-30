import Foundation
import Combine

@MainActor
protocol WidgetContainerContentViewModelProtocol: AnyObject, ObservableObject {
    var name: String { get }
    var count: String? { get }
    var menuItems: [WidgetMenuItem] { get }
    var allowContent: Bool { get }
    
    func onAppear()
    func onDisappear()
}

// Default Implementation

extension WidgetContainerContentViewModelProtocol {
    var count: String? { nil }
    var menuItems: [WidgetMenuItem] { [.changeSource, .changeType, .remove] }
    var allowContent: Bool { true }
}
