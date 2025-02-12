import Foundation
import Services

@MainActor
protocol WidgetSourceSearchInternalViewModelProtocol: AnyObject {
    func onSelect(source: WidgetSource, openObject: ScreenData?)
}
