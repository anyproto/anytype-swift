import Foundation
import Combine

@MainActor
protocol WidgetContainerContentViewModelProtocol: AnyObject, ObservableObject {
    func startHeaderSubscription()
    func startContentSubscription()
    func onHeaderTap()
}
