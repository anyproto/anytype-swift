import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore

final class DashboardService: DashboardServiceProtocol {
    
    private let objectsService = ServiceLocator.shared.objectActionsService()
    
    func createNewPage() -> AnytypeId? {
        let defaultTypeUrl = ObjectTypeProvider.defaultObjectType.url
        let id = objectsService.createPage(
            contextId: "",
            targetId: "",
            details: [.name(""), .isDraft(true), .type(.dynamic(defaultTypeUrl))],
            position: .bottom,
            templateId: ""
        )
        
        return id?.asAnytypeId
    }
    
}
