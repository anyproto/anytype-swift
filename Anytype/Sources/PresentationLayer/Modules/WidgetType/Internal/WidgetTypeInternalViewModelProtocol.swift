import Foundation
import BlocksModels

protocol WidgetTypeInternalViewModelProtocol: AnyObject {
    func onTap(layout: BlockWidget.Layout)
}
