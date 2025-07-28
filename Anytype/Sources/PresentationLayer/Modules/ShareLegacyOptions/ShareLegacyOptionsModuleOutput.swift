import Foundation

@MainActor
protocol ShareLegacyOptionsModuleOutput: AnyObject {
    func onSpaceSelection(completion: @escaping (SpaceView) -> Void)
    func onDocumentSelection(data: ObjectSearchModuleData)
}
