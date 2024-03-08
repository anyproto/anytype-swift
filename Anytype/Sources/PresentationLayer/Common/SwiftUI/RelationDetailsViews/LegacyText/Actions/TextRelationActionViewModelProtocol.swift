import Foundation

@MainActor
protocol TextRelationActionViewModelProtocol: AnyObject {
    var id: String { get }
    var inputText: String { get set }
    var title: String { get }
    var iconAsset: ImageAsset { get }
    var isActionAvailable: Bool { get }
    func performAction()
}
