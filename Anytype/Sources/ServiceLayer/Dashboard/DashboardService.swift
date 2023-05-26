import Foundation
import Combine
import Services
import ProtobufMessages
import AnytypeCore

final class DashboardService: DashboardServiceProtocol {
    
    private let searchService: SearchServiceProtocol
    private let pageService: PageServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol

    init(searchService: SearchServiceProtocol, pageService: PageServiceProtocol, objectTypeProvider: ObjectTypeProviderProtocol) {
        self.searchService = searchService
        self.pageService = pageService
        self.objectTypeProvider = objectTypeProvider
    }
    
    // MARK: - DashboardServiceProtocol
    
    func createNewPage() -> ObjectDetails? {
        let availableTemplates = searchService.searchTemplates(
            for: .dynamic(objectTypeProvider.defaultObjectType.id)
        )
        let hasSingleTemplate = availableTemplates?.count == 1
        let templateId = hasSingleTemplate ? (availableTemplates?.first?.id ?? "") : ""

        let details = pageService.createPage(
            name: "",
            shouldDeleteEmptyObject: true,
            shouldSelectType: true,
            shouldSelectTemplate: true,
            templateId: templateId
        )
        
        return details
    }
    
}
