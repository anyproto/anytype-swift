import AnytypeCore
import Services

protocol DashboardServiceProtocol {
    
    func createNewPage() async throws -> ObjectDetails
}
