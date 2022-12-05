import Foundation
import SwiftEntryKit

final class AlertOpener: AlertOpenerProtocol {
    
    // MARK: - AlertOpenerProtocol
    
    func showTopAlert(message: String) {
        let view = TopAlertView(title: message)

        var attributes = EKAttributes()
        attributes.positionConstraints = .float
        attributes.positionConstraints.safeArea = .empty(fillSafeArea: false)
        attributes.windowLevel = .statusBar
        attributes.positionConstraints.size = .init(width: .intrinsic, height: .intrinsic)
        attributes.position = .top
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 5, offset: .zero))
        
        SwiftEntryKit.display(entry: view, using: attributes)
    }
}
