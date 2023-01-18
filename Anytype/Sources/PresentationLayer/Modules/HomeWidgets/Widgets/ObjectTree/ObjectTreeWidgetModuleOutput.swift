import Foundation

@MainActor
protocol ObjectTreeWidgetModuleOutput: AnyObject {
    func onObjectSelected(screenData: EditorScreenData)
}
