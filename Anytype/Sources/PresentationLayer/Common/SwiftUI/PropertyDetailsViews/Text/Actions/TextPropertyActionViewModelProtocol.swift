import Foundation

@MainActor
protocol TextPropertyActionViewModelProtocol: AnyObject {
    var id: String { get }
    var inputText: String { get set }
    var title: String { get }
    var iconAsset: ImageAsset { get }
    var isActionAvailable: Bool { get }
    func performAction()
}
