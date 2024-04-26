import AnytypeCore

final class MiddlewareMerticsConfigurator: AppConfiguratorProtocol {
    
    private let metricsService = ServiceLocator.shared.metricsService()
    
    func configure() {
        let appVersion = MetadataProvider.appVersion ?? ""
        let buildNumber = MetadataProvider.buildNumber ?? ""
        let metricsEnv = CoreEnvironment.isDebug ? "-dev" : ""
        let version = appVersion + "(\(buildNumber))" + metricsEnv
        Task {
            try await metricsService.metricsSetParameters(platform: "iOS", version: version)
        }
    }
}
