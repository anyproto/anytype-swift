import Foundation
import Factory
import Services
import AnytypeCore

final class HomepagePickerService: HomepagePickerServiceProtocol {

    private let objectActionsService: any ObjectActionsServiceProtocol
    private let workspaceService: any WorkspaceServiceProtocol

    init() {
        self.objectActionsService = Container.shared.objectActionsService()
        self.workspaceService = Container.shared.workspaceService()
    }

    func setHomepage(spaceId: String, homepage: SpaceHomepage) async throws {
        try await workspaceService.setHomepage(spaceId: spaceId, homepage: homepage.rawValue)
    }

    func createHomepage(spaceId: String, option: HomepagePickerOption) async throws -> HomepageValue {
        switch option {
        case .widgets:
            try await setHomepage(spaceId: spaceId, homepage: .widgets)
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
            try await setHomepage(spaceId: spaceId, homepage: .object(objectId: details.id))
            return .object(details: details)
        }
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
