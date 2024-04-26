import Foundation

@MainActor
protocol ShareOptionsModuleOutput: AnyObject {
    func onSpaceSelection(completion: @escaping (SpaceView) -> Void)
    func onDocumentSelection(data: SearchModuleModel)
}
