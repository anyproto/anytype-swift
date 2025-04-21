import Foundation


@MainActor
final class AppConfigurator {
    
    private let configurators: [any AppConfiguratorProtocol] = [
        AppVersionTrackerConfigurator(),
        NonFatalAlertConfigurator(),
        GlobalScaleConfiguration(),
        MiddlewareMerticsConfigurator(),
        MiddlewareHandlerConfigurator(),
        SentryConfigurator(),
        AnalyticsConfigurator(),
        KingfisherConfigurator(),
        AudioPlaybackConfigurator(),
        iCloudBackupConfigurator(),
        ViewProvidersConfigurator(),
        TipsConfiguration(),
        GlobalServicesConfiguration(),
        FirebaseConfigurator()
    ]

    func configure() {
        configurators.forEach {
            $0.configure()
        }
    }
    
}
