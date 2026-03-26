import Foundation
import Factory
import Services
import AnytypeCore

final class HomepagePickerService: HomepagePickerServiceProtocol {

    private static let widgetsHomepageId = "widgets"

    private let objectActionsService: any ObjectActionsServiceProtocol
    private let workspaceService: any WorkspaceServiceProtocol

    init() {
        self.objectActionsService = Container.shared.objectActionsService()
        self.workspaceService = Container.shared.workspaceService()
    }

    func createHomepage(spaceId: String, option: HomepagePickerOption) async throws -> HomepageValue {
        switch option {
        case .widgets:
            try await setHomepage(spaceId: spaceId, homepageId: Self.widgetsHomepageId)
            return .widgets
        case .object(let type):
            let details = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: type.objectTypeKey,
                shouldDeleteEmptyObject: false,
                shouldSelectType: false,
                shouldSelectTemplate: false,
                spaceId: spaceId,
                origin: .none,
                templateId: nil,
                createdInContext: "",
                createdInContextRef: ""
            )
            try await setHomepage(spaceId: spaceId, homepageId: details.id)
            return .object(id: details.id)
        }
    }

    private func setHomepage(spaceId: String, homepageId: String) async throws {
        try await workspaceService.setHomepage(spaceId: spaceId, homepage: homepageId)
    }
}

private extension ObjectHomepageType {

    var objectTypeKey: ObjectTypeUniqueKey {
        switch self {
        case .chat: return .chatDerived
        case .page: return .page
        case .collection: return .collection
        }
    }
}
