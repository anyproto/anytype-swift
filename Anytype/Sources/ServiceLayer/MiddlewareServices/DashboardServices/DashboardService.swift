import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import Amplitude


class DashboardService: DashboardServiceProtocol {
    private let configurationService = MiddlewareConfigurationService()
    private let actionsService = BlockActionsServiceSingle()
    private let objectsService = ObjectActionsService()
    
    private var dashboardId: String = ""
    
    private var subscriptions = [AnyCancellable]()
        
    func openDashboard(completion: @escaping (ResponseEvent) -> ()) {
        configurationService.obtainConfiguration { [weak self] config in
            guard let self = self else { return }
            
            self.actionsService.open(contextID: config.homeBlockID, blockID: config.homeBlockID)
                .sinkWithDefaultCompletion("Open dashboard") { success in
                    completion(success)
                }
                .store(in: &self.subscriptions)
        }
    }
    
    func createNewPage() -> CreatePageResult {
        Amplitude.instance().logEvent(AmplitudeEventsName.pageCreate)
        return objectsService.createPage(
            contextID: "",
            targetID: "",
            details: [.name: DetailsEntry(value: "")],
            position: .bottom,
            templateID: ""
        )
    }
    
    private func save(configuration: MiddlewareConfiguration) -> MiddlewareConfiguration {
        self.dashboardId = configuration.homeBlockID
        return configuration
    }
}
