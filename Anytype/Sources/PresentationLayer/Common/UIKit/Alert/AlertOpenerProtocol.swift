import Foundation


@MainActor
protocol AlertOpenerProtocol: AnyObject {
    @discardableResult
    func showFloatAlert(model: BottomAlertLegacy) -> AnytypeDismiss
}
