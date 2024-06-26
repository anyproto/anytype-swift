import AnytypeCore
import Services


final class MiddlewareMerticsConfigurator: AppConfiguratorProtocol {
    
    @Injected(\.metricsService)
    private var metricsService:any MetricsServiceProtocol
    
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
