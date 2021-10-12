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
        
    func openDashboard() -> ResponseEvent? {
        let homeBlockId = configurationService.configuration().homeBlockID
        return actionsService.open(contextId: homeBlockId, blockId: homeBlockId)
    }
    
    func createNewPage() -> CreatePageResponse? {
        Amplitude.instance().logEvent(AmplitudeEventsName.pageCreate)
        return objectsService.createPage(
            contextID: "",
            targetID: "",
            details: [.name: DetailsEntry(value: "")],
            position: .bottom,
            templateID: ""
        )
    }
}
