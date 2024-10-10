import Foundation

final class AppVersionTrackerConfigurator: AppConfiguratorProtocol {

    @Injected(\.appVersionTracker)
    private var appVersionTracker: any AppVersionTrackerProtocol
    
    func configure() {
        appVersionTracker.trackLaunch()
    }
}
