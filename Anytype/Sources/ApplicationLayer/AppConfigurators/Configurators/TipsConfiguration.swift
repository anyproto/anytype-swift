import Foundation
import TipKit
import AnytypeCore

final class TipsConfiguration: AppConfiguratorProtocol {
    
    @Injected(\.userWarningAlertsHandler)
    private var userWarningAlertsHandler: any UserWarningAlertsHandlerProtocol
        
    func configure() {
        if #available(iOS 17.0, *) {
            do {
                if FeatureFlags.userWarningAlerts, userWarningAlertsHandler.getNextUserWarningAlert().isNotNil {
                    // skip Tips for this launch
                    return
                }
                
                if FeatureFlags.resetTips {
                    try Tips.resetDatastore()
                }
                if FeatureFlags.showAllTips {
                    try Tips.configure([.displayFrequency(.immediate), .datastoreLocation(.applicationDefault)])
                } else {
                    try Tips.configure([.displayFrequency(.daily), .datastoreLocation(.applicationDefault)])
                }
            } catch {
                anytypeAssertionFailure("Tips setup error", info: ["tipsError": error.localizedDescription])
            }
        }
    }
}
