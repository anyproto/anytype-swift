import Foundation

protocol AlertOpenerProtocol: AnyObject {
    func showTopAlert(message: String)
    func showLoadingAlert(message: String) -> AnytypeDismiss
    @discardableResult
    func showFloatAlert(model: BottomAlertLegacy) -> AnytypeDismiss
}
