import Foundation


@MainActor
protocol AlertOpenerProtocol: AnyObject {
    func showTopAlert(message: String)
    @discardableResult
    func showFloatAlert(model: BottomAlertLegacy) -> AnytypeDismiss
}
