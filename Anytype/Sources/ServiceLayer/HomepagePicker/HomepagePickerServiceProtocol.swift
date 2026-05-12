import Foundation

protocol HomepagePickerServiceProtocol: Sendable {
    /// Sets homepage to an existing value (widgets or object ID). No object creation.
    func setHomepage(spaceId: String, homepage: SpaceHomepage) async throws

    /// Creates the homepage object (if needed) and sets it as homepage.
    func createHomepage(spaceId: String, option: HomepagePickerOption) async throws -> HomepageValue
}
