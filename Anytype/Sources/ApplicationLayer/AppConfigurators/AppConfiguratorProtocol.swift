import UIKit

public protocol AppConfiguratorProtocol {
    
    @MainActor
    func configure()
    
}
