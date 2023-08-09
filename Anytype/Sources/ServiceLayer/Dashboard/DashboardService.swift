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
    
    func createNewPage(spaceId: String) async throws -> ObjectDetails {
        let details = try await pageService.createPage(
            name: "",
            shouldDeleteEmptyObject: true,
            shouldSelectType: true,
            shouldSelectTemplate: true,
            spaceId: spaceId
        )
        
        return details
    }
    
}
