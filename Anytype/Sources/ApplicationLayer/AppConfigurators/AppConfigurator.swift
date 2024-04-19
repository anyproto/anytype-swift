import Foundation


@MainActor
final class AppConfigurator {
    
    private let configurators: [AppConfiguratorProtocol] = [
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
        TipsConfiguration()
    ]

    func configure() {
        configurators.forEach {
            $0.configure()
        }
    }
    
}
