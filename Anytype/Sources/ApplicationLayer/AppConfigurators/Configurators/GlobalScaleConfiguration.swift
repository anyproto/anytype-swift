import Foundation
import UIKit

final class GlobalScaleConfiguration: AppConfiguratorProtocol {
    
    func configure() {
        ScaleProvider.shared.scale = UIScreen.main.scale
    }
}
