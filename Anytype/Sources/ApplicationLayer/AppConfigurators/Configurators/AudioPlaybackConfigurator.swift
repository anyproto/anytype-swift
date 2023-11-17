import AVFoundation
import UIKit

final class AudioPlaybackConfigurator: AppConfiguratorProtocol {

    private let audioSessionService = ServiceLocator.shared.audioSessionService()
    
    func configure() {
        audioSessionService.setCategorypPlaybackMixWithOthers()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
}
