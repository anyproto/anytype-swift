import AVFoundation
import UIKit
import AnytypeCore


final class AudioPlaybackConfigurator: AppConfiguratorProtocol {

    private let audioSessionService = ServiceLocator.shared.audioSessionService()
    
    func configure() {
        if FeatureFlags.fixAudioSession {
            audioSessionService.setCategorypPlaybackMixWithOthers()
        } else {
            audioSessionService.setCategorypPlaybackLegacy()
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
}
