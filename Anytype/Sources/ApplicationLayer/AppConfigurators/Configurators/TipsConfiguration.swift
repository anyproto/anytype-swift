import Foundation
import TipKit
import AnytypeCore

final class TipsConfiguration: AppConfiguratorProtocol {
        
    func configure() {
        if #available(iOS 17, *) {
            if FeatureFlags.resetTips {
                try? Tips.resetDatastore()
            }
            if FeatureFlags.showAllTips {
                Tips.showAllTipsForTesting()
            }
            try? Tips.configure([.displayFrequency(.daily)])
        }

    }
}
