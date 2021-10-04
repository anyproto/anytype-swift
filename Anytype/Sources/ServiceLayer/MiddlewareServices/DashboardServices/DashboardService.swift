import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import Amplitude


class DashboardService: DashboardServiceProtocol {
    private let configurationService = MiddlewareConfigurationService.shared
    private let actionsService = BlockActionsServiceSingle()
    private let objectsService = ObjectActionsService()
    
    private var dashboardId: String = ""
    
    private var subscriptions = [AnyCancellable]()
        
    func openDashboard(completion: @escaping (ResponseEvent) -> ()) {
        guard
            let homeBlockID = configurationService.configuration()?.homeBlockID
        else { return }
        
        actionsService.open(contextID: homeBlockID, blockID: homeBlockID)
            .sinkWithDefaultCompletion("Open dashboard") { success in
                completion(success)
            }
            .store(in: &self.subscriptions)
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
