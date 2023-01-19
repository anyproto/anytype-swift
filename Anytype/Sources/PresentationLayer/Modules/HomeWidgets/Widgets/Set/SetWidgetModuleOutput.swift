import Foundation

@MainActor
protocol SetWidgetModuleOutput: AnyObject {
    func onObjectSelected(screenData: EditorScreenData)
}
