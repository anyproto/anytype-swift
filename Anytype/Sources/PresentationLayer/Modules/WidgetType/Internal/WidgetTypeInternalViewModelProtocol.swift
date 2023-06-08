import Foundation
import BlocksModels
import Combine

struct WidgetTypeState {
    let source: WidgetSource
    let layout: BlockWidget.Layout?
}

protocol WidgetTypeInternalViewModelProtocol: AnyObject {
    var statePublisher: AnyPublisher<WidgetTypeState?, Never> { get }
    func onTap(layout: BlockWidget.Layout)
}
