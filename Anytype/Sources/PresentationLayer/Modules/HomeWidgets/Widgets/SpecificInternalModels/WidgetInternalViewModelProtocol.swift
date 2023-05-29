import Foundation
import Combine
import BlocksModels

protocol WidgetInternalViewModelProtocol: AnyObject {
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { get }
    var namePublisher: AnyPublisher<String, Never> { get }
    
    func startHeaderSubscription()
    func stopHeaderSubscription()
    func startContentSubscription()
    func stopContentSubscription()
    func screenData() -> EditorScreenData?
    func analyticsSource() -> AnalyticsWidgetSource
}
