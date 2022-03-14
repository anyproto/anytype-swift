import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import Amplitude


class DashboardService: DashboardServiceProtocol {
    private let objectsService = ServiceLocator.shared.objectActionsService()
    
    func createNewPage() -> BlockId? {
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
