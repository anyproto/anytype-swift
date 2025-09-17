import Foundation
import Combine
import Services

@MainActor
protocol WidgetInternalViewModelProtocol: AnyObject {
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { get }
    var namePublisher: AnyPublisher<String, Never> { get }
    var iconPublisher: AnyPublisher<Icon?, Never> { get }
    var allowCreateObject: Bool { get }
    
    func startHeaderSubscription()
    func startContentSubscription() async
    func screenData() -> ScreenData?
    func analyticsSource() -> AnalyticsWidgetSource
    func onCreateObjectTap()
}

extension WidgetInternalViewModelProtocol {
    var allowCreateObject: Bool { false }
    var iconPublisher: AnyPublisher<Icon?, Never> { Just(nil).eraseToAnyPublisher() }
    func onCreateObjectTap() {}
}
