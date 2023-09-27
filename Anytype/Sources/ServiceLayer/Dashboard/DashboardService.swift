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
    
    func createNewPage() async throws -> ObjectDetails {
        let details = try await pageService.createDefaultPage(
            name: "",
            shouldDeleteEmptyObject: true
        )
        return details
    }
    
}
