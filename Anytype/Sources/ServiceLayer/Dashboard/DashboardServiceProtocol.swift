import AnytypeCore
import Services

protocol DashboardServiceProtocol {
    
    func createNewPage(spaceId: String) async throws -> ObjectDetails
    func createNewPage(spaceId: String, typeUniqueKey: ObjectTypeUniqueKey) async throws -> ObjectDetails
}
