import Foundation
import TipKit
import AnytypeCore

final class TipsConfiguration: AppConfiguratorProtocol {
        
    func configure() {
        if #available(iOS 17.0, *) {
            do {
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
