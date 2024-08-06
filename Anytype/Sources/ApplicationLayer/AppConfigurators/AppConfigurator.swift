import Foundation


@MainActor
final class AppConfigurator {
    
    private let configurators: [any AppConfiguratorProtocol] = [
        EnvironmentConfiguration(),
        NonFatalAlertConfigurator(),
        MiddlewareMerticsConfigurator(),
        MiddlewareHandlerConfigurator(),
        SentryConfigurator(),
        AnalyticsConfigurator(),
        KingfisherConfigurator(),
        AudioPlaybackConfigurator(),
        iCloudBackupConfigurator(),
        ViewProvidersConfigurator(),
        TipsConfiguration(),
        GlobalServicesConfiguration()
    ]

    func configure() {
        configurators.forEach {
            $0.configure()
        }
    }
    
}
