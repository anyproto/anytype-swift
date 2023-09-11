import Foundation
import Combine
import Services
import ProtobufMessages
import AnytypeCore

final class DashboardService: DashboardServiceProtocol {
    
    private let searchService: SearchServiceProtocol
    private let pageService: PageRepositoryProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol

    init(searchService: SearchServiceProtocol, pageService: PageRepositoryProtocol, objectTypeProvider: ObjectTypeProviderProtocol) {
        self.searchService = searchService
        self.pageService = pageService
        self.objectTypeProvider = objectTypeProvider
    }
    
    // MARK: - DashboardServiceProtocol
    
    func createNewPage() async throws -> ObjectDetails {
        let details = try await pageService.createDefaultPage(
            name: "",
            shouldDeleteEmptyObject: true,
            shouldSelectType: true,
            shouldSelectTemplate: true
        )
        
        return details
    }
    
}
