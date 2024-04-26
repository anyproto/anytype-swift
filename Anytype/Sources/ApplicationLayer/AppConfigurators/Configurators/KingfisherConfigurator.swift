import Kingfisher
import UIKit

final class KingfisherConfigurator: AppConfiguratorProtocol {
    
    func configure() {
        KingfisherManager.shared.defaultOptions = [
            .scaleFactor(UIScreen.main.scale),
            .backgroundDecode,
            .diskCacheExpiration(.days(1)),
            .retryStrategy(
                DelayRetryStrategy(maxRetryCount: 5, retryInterval: .seconds(2))
            ),
            .keepCurrentImageWhileLoading
        ]
    }
    
}
