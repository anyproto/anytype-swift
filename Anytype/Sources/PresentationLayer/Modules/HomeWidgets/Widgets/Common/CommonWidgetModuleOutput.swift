import Foundation

@MainActor
protocol CommonWidgetModuleOutput: AnyObject {
    func onObjectSelected(screenData: EditorScreenData)
}
