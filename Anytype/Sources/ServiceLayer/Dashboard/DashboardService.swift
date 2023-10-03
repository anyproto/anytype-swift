import Foundation
import Combine
import Services
import ProtobufMessages
import AnytypeCore

final class DashboardService: DashboardServiceProtocol {
    
    private let searchService: SearchServiceProtocol
    private let pageService: PageRepositoryProtocol

    init(searchService: SearchServiceProtocol, pageService: PageRepositoryProtocol) {
        self.searchService = searchService
        self.pageService = pageService
    }
    
    // MARK: - DashboardServiceProtocol
    
    func createNewPage(spaceId: String) async throws -> ObjectDetails {
        let details = try await pageService.createDefaultPage(
            name: "",
            shouldDeleteEmptyObject: true,
            spaceId: spaceId
        )
        return details
    }
    
    func createNewPage(spaceId: String, typeUniqueKey: ObjectTypeUniqueKey) async throws -> ObjectDetails {
        let details = try await pageService.createPage(
            name: "",
            typeUniqueKey: typeUniqueKey,
            shouldDeleteEmptyObject: true,
            shouldSelectType: false,
            shouldSelectTemplate: true,
            spaceId: spaceId,
            templateId: nil
        )
        return details
    }
    
}
