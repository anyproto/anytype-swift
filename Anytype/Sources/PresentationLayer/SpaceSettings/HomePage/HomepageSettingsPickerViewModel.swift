import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class HomepageSettingsPickerViewModel {

    @ObservationIgnored @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @ObservationIgnored @Injected(\.homepagePickerService)
    private var homepagePickerService: any HomepagePickerServiceProtocol

    var searchText = ""
    var objects: [ObjectDetails] = []
    var dismiss = false

    let currentObjectId: String?

    @ObservationIgnored
    private let spaceId: String

    init(spaceId: String) {
        self.spaceId = spaceId
        let spaceView = Container.shared.spaceViewsStorage().spaceView(spaceId: spaceId)
        let homepage = spaceView?.homepage ?? .empty
        switch homepage {
        case .empty, .widgets:
            self.currentObjectId = nil
        case .object(let objectId):
            self.currentObjectId = objectId
        }
    }

    func search() async {
        do {
            try await Task.sleep(for: .milliseconds(300))
            let layouts: [DetailsLayout] = DetailsLayout.visibleLayoutsWithFiles(spaceUxType: nil)
            objects = try await searchService.searchObjectsWithLayouts(
                text: searchText,
                layouts: layouts,
                excludedIds: [],
                spaceId: spaceId
            ).filter { !$0.isArchivedOrDeleted }
        } catch is CancellationError {
            // Ignore
        } catch {
            objects = []
        }
    }

    func onEmptySelected() async throws {
        try await homepagePickerService.setHomepage(spaceId: spaceId, homepage: .widgets)
        dismiss = true
    }

    func onObjectSelected(_ details: ObjectDetails) async throws {
        try await homepagePickerService.setHomepage(spaceId: spaceId, homepage: .object(objectId: details.id))
        dismiss = true
    }
}
