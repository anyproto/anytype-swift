import Foundation
import Combine
import Services

@MainActor
protocol WidgetInternalViewModelProtocol: AnyObject {
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { get }
    var namePublisher: AnyPublisher<String, Never> { get }
    
    func startHeaderSubscription()
    func stopHeaderSubscription()
    func startContentSubscription() async
    func stopContentSubscription() async
    func screenData() -> EditorScreenData?
    func analyticsSource() -> AnalyticsWidgetSource
}
