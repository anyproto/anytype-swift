import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import Amplitude


class DashboardService: DashboardServiceProtocol {
    private let objectsService = ObjectActionsService()
    
    func createNewPage() -> BlockId? {
        #warning("replace with CreateObject")
//        Amplitude.instance().logEvent(AmplitudeEventsName.pageCreate)
        let defaultTypeUrl = ObjectTypeProvider.defaultObjectType.url
        return objectsService.createPage(
            contextId: "",
            targetId: "",
            details: [.name(""), .isDraft(true), .type(.dynamic(defaultTypeUrl))],
            position: .bottom,
            templateId: ""
        )
    }
}
