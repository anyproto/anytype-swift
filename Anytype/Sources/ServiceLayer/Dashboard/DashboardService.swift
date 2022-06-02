import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore

final class DashboardService: DashboardServiceProtocol {
    
    private let objectsService = ServiceLocator.shared.objectActionsService()
    
    func createNewPage(isDraft: Bool, templateId: BlockId?) -> BlockId? {
        let defaultTypeUrl = ObjectTypeProvider.defaultObjectType.url
        let id = objectsService.createPage(
            contextId: "",
            targetId: "",
            details: [
                .name(""),
                .isDraft(isDraft),
                .type(.dynamic(defaultTypeUrl))
            ],
            position: .bottom,
            templateId: templateId ?? ""
        )

        if id.isNotNil {
            AnytypeAnalytics.instance().logCreateObject(objectType: defaultTypeUrl, route: .home)
        }
        
        return id
    }
    
}
