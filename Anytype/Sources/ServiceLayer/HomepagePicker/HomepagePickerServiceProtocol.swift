import Foundation

protocol HomepagePickerServiceProtocol: Sendable {
    /// Creates the homepage object (if needed) and sets it as homepage.
    /// Returns the homepageId (objectId for Chat/Page/Collection, "widgets" for Widgets).
    func createHomepage(spaceId: String, option: HomepagePickerOption) async throws -> String
}
