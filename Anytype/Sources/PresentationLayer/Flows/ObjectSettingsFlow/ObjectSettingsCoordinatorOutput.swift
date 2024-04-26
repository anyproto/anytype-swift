import Foundation

protocol ObjectSettingsCoordinatorOutput: AnyObject {
    func closeEditor()
    func showPage(data: EditorScreenData)
}
