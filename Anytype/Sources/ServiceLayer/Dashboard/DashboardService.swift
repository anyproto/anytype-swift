import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore

final class DashboardService: DashboardServiceProtocol {
    
    private let searchService: SearchServiceProtocol
    private let pageService: PageServiceProtocol
    
    init(searchService: SearchServiceProtocol, pageService: PageServiceProtocol) {
        self.searchService = searchService
        self.pageService = pageService
    }
    
    // MARK: - DashboardServiceProtocol
    
    func createNewPage() -> BlockId? {
        let availableTemplates = searchService.searchTemplates(
            for: .dynamic(ObjectTypeProvider.shared.defaultObjectType.id)
        )
        let hasSingleTemplate = availableTemplates?.count == 1
        let templateId = hasSingleTemplate ? (availableTemplates?.first?.id ?? "") : ""

        let id = pageService.createPage(
            name: "",
            shouldDeleteEmptyObject: true,
            shouldSelectType: true,
            shouldSelectTemplate: true,
            templateId: templateId
        )
        
        return id
    }
    
}
