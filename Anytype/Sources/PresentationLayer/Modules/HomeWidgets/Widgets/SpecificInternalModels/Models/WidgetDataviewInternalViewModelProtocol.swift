import Foundation
import Combine
import Services

struct WidgetDataviewState {
    let dataview: [DataviewView]
    let activeViewId: String
}

@MainActor
protocol WidgetDataviewInternalViewModelProtocol: WidgetInternalViewModelProtocol {
    var dataviewPublisher: AnyPublisher<WidgetDataviewState?, Never> { get }
    func onActiveViewTap(_ viewId: String)
}
