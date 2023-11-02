import Foundation
import Services
import UIKit

extension AlertsFactory {
    
    static func objectOpenErrorAlert(error: Error, closeAction: @escaping () -> Void) -> UIAlertController {
        guard let error = error as? ObjectOpenError else {
            return unknownAlert(closeAction: closeAction)
        }
        
        switch error {
        case .anytypeNeedsUpgrade:
            return needsUpgradeAlert(closeAction: closeAction)
        case .unknownError:
            return unknownAlert(closeAction: closeAction)
        }
    }
    
    private static func unknownAlert(closeAction: @escaping () -> Void) -> UIAlertController {
        let model = AlertModel(
            title: Loc.error,
            message: Loc.unknownError,
            buttons: [
                AlertModel.ButtonModel(title: Loc.close, style: .default, action: {
                    closeAction()
                })
            ]
        )
        return AlertsFactory.alertController(from: model)
    }
    
    private static func needsUpgradeAlert(closeAction: @escaping () -> Void) -> UIAlertController {
        let model = AlertModel(
            title: Loc.Error.AnytypeNeedsUpgrate.title,
            message: Loc.Error.AnytypeNeedsUpgrate.message,
            buttons: [
                AlertModel.ButtonModel(title: Loc.close, style: .default, action: {
                    closeAction()
                })
            ]
        )
        return AlertsFactory.alertController(from: model)
    }
}
