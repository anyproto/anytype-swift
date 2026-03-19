import Foundation
import Services
import AnytypeCore

final class HomepagePickerService: HomepagePickerServiceProtocol, @unchecked Sendable {

    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol

    func createHomepage(spaceId: String, option: HomepagePickerOption) async throws -> String {
        switch option {
        case .widgets:
            try await setHomepage(spaceId: spaceId, homepageId: HomepageValue.widgets)
            return HomepageValue.widgets
        case .chat, .page, .collection:
            guard let typeKey = option.objectTypeKey else {
                anytypeAssertionFailure("Option \(option) should have objectTypeKey")
                throw HomepagePickerServiceError.missingObjectType
            }
            let details = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: typeKey,
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
            return details.id
        }
    }

    // MARK: - Stub

    /// TODO: Replace with Rpc.Workspace.SetHomepage when middleware #2 is ready
    private func setHomepage(spaceId: String, homepageId: String) async throws {
        anytypeAssertionFailure("SetHomepage stub called: spaceId=\(spaceId), homepageId=\(homepageId)")
    }
}

enum HomepagePickerServiceError: Error {
    case missingObjectType
}
