import Foundation


@MainActor
protocol AlertOpenerProtocol: AnyObject {
    func showLoadingAlert(message: String) -> AnytypeDismiss
    @discardableResult
    func showFloatAlert(model: BottomAlertLegacy) -> AnytypeDismiss
}
