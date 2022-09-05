import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore

final class DashboardService: DashboardServiceProtocol {
    
    private let searchService = ServiceLocator.shared.searchService()
    private let objectsService = ServiceLocator.shared.objectActionsService()
    
    func createNewPage() -> BlockId? {
        let availableTemplates = searchService.searchTemplates(
            for: .dynamic(ObjectTypeProvider.shared.defaultObjectType.id)
        )
        let hasSingleTemplate = availableTemplates?.count == 1
        let templateId = hasSingleTemplate ? (availableTemplates?.first?.id ?? "") : ""

        let id = objectsService.createPage(
            contextId: "",
            targetId: "",
            details: [
                .name(""),
                .type(.dynamic(ObjectTypeProvider.shared.defaultObjectType.id))
            ],
            shouldDeleteEmptyObject: true,
            shouldSelectType: true,
            shouldSelectTemplate: true,
            position: .bottom,
            templateId: templateId
        )
        
        return id
    }
    
}
