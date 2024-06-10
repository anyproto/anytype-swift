import Foundation
import Combine

@MainActor
protocol WidgetContainerContentViewModelProtocol: AnyObject, ObservableObject {
    func startHeaderSubscription()
    func startContentSubscription()
    func onHeaderTap()
    func onCreateObjectTap()
}

// Default Implementation

extension WidgetContainerContentViewModelProtocol {
    func onCreateObjectTap() {}
}
