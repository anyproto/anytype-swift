import Foundation
import Services

@MainActor
@Observable
final class HomepageCreatePickerViewModel {

    @ObservationIgnored @Injected(\.homepagePickerService)
    private var homepagePickerService: any HomepagePickerServiceProtocol

    var selectedOption: HomepagePickerOption = .object(.chat)
    var dismiss = false

    let options = HomepagePickerOption.allCases

    @ObservationIgnored
    private let spaceId: String
    @ObservationIgnored
    private let onFinish: (HomepagePickerResult) async throws -> Void

    init(spaceId: String, onFinish: @escaping (HomepagePickerResult) async throws -> Void) {
        self.spaceId = spaceId
        self.onFinish = onFinish
    }

    func onCreate() async throws {
        AnytypeAnalytics.instance().logCreateHomePage(type: selectedOption.analyticsType)
        let homepageValue = try await homepagePickerService.createHomepage(
            spaceId: spaceId,
            option: selectedOption
        )
        try await onFinish(.homepageSet(homepageValue))
        dismiss = true
    }

    func onNotNow() async throws {
        try await homepagePickerService.setHomepage(spaceId: spaceId, homepage: .widgets)
        try await onFinish(.later)
        dismiss = true
    }
}
