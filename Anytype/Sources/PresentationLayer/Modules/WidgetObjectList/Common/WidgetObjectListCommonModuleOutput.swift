import Foundation

@MainActor
protocol WidgetObjectListCommonModuleOutput: AnyObject {
    func onObjectSelected(screenData: ScreenData)
}
