import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import Amplitude


class DashboardService: DashboardServiceProtocol {
    private let objectsService = ObjectActionsService()
    
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
