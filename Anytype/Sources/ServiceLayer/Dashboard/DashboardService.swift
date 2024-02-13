import Foundation
import Combine
import Services
import ProtobufMessages
import AnytypeCore

final class DashboardService: DashboardServiceProtocol {
    
    private let pageService: PageRepositoryProtocol
    private let objectService: ObjectActionsServiceProtocol

    init(pageService: PageRepositoryProtocol, objectService: ObjectActionsServiceProtocol) {
        self.objectService = objectService
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
    
    func createNewPage(spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, templateId: String) async throws -> ObjectDetails {
        let details = try await objectService.createObject(
            name: "",
            typeUniqueKey: typeUniqueKey,
            shouldDeleteEmptyObject: true,
            shouldSelectType: false,
            shouldSelectTemplate: true,
            spaceId: spaceId,
            origin: .none,
            templateId: templateId
        )
        return details
    }
    
}
