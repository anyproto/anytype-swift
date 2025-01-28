import AnytypeCore
import Services


final class MiddlewareMerticsConfigurator: AppConfiguratorProtocol {
    
    @Injected(\.metricsService)
    private var metricsService: any MetricsServiceProtocol
    
    func configure() {
        let appVersion = MetadataProvider.appVersion ?? ""
        let buildNumber = MetadataProvider.buildNumber ?? ""
        let metricsEnv = CoreEnvironment.targetType.isDebug ? "-dev" : ""
        let version = appVersion + "(\(buildNumber))" + metricsEnv
        Task {
            try await metricsService.setInitialParameters(platform: "iOS", version: version)
        }
    }
}
