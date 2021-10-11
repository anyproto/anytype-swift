import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import Amplitude


class DashboardService: DashboardServiceProtocol {
    private let actionsService = BlockActionsServiceSingle()
    private let objectsService = ObjectActionsService()
            
    func openDashboard(homeBlockId: String) -> ResponseEvent? {
        actionsService.open(contextId: homeBlockId, blockId: homeBlockId)
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
