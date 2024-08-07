import AVFoundation
import UIKit

final class AudioPlaybackConfigurator: AppConfiguratorProtocol {

    @Injected(\.audioSessionService)
    private var audioSessionService: any AudioSessionServiceProtocol
    
    func configure() {
        audioSessionService.setCategorypPlaybackMixWithOthers()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
}
