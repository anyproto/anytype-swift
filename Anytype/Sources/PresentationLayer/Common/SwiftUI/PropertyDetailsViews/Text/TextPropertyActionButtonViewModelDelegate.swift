import Foundation

@MainActor
protocol TextPropertyActionButtonViewModelDelegate: AnyObject {
    func canOpenUrl(_ url: URL) -> Bool
    func openUrl(_ url: URL)
    func showActionSuccessMessage(_ text: String)
}
