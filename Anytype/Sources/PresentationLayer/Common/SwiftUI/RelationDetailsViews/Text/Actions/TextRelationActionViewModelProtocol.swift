import Foundation

@MainActor
protocol TextRelationActionViewModelProtocol: AnyObject {
    var inputText: String { get set }
    var title: String { get }
    var iconAsset: ImageAsset { get }
    var isActionAvailable: Bool { get }
    func performAction()
}
