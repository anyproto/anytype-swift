import AnytypeCore
import Services

protocol DashboardServiceProtocol {
    
    func createNewPage(spaceId: String) async throws -> ObjectDetails
}
