import Foundation

protocol HomepagePickerServiceProtocol: Sendable {
    /// Creates the homepage object (if needed) and sets it as homepage.
    func createHomepage(spaceId: String, option: HomepagePickerOption) async throws -> HomepageValue
}
