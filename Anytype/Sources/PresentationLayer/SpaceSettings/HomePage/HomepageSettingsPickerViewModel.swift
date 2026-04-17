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
    @ObservationIgnored @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol

    var searchText = ""
    var objects: [ObjectDetails] = []
    var dismiss = false
    var isSearchCompleted = false

    let currentObjectId: String?
    var isNoHomeSelected: Bool { currentObjectId == nil }

    var showNoHomeRow: Bool {
        let noHomeTitle = Loc.SpaceSettings.HomePage.noHome.lowercased()
        return searchText.isEmpty || noHomeTitle.contains(searchText.lowercased())
    }

    @ObservationIgnored
    private let spaceId: String

    @ObservationIgnored
    private let onHomepageSet: ((AnyHashable) -> Void)?

    init(spaceId: String, onHomepageSet: ((AnyHashable) -> Void)?) {
        self.spaceId = spaceId
        self.onHomepageSet = onHomepageSet
        let homepage = Container.shared.spaceViewsStorage().spaceView(spaceId: spaceId)?.homepage ?? .empty
        switch homepage.displayValue {
        case .empty, .widgets, .graph:
            self.currentObjectId = nil
        case .object(let objectId):
            self.currentObjectId = objectId
        }
    }

    func search() async {
        do {
            try await Task.sleep(for: .milliseconds(300))
            let layouts: [DetailsLayout] = DetailsLayout.visibleLayoutsWithFiles(spaceType: spaceViewsStorage.spaceView(spaceId: spaceId)?.spaceType)
            objects = try await searchService.searchObjectsWithLayouts(
                text: searchText,
                layouts: layouts,
                excludedIds: [],
                spaceId: spaceId
            ).filter { !$0.isArchivedOrDeleted }
            isSearchCompleted = true
        } catch is CancellationError {
            // Ignore
        } catch {
            objects = []
            isSearchCompleted = true
        }
    }

    func onNoHomeSelected() async throws {
        try await homepagePickerService.setHomepage(spaceId: spaceId, homepage: .widgets)
        AnytypeAnalytics.instance().logChangeSpaceDashboard()
        onHomepageSet?(HomeWidgetData(spaceId: spaceId))
        dismiss = true
    }

    func onObjectSelected(_ details: ObjectDetails) async throws {
        try await homepagePickerService.setHomepage(spaceId: spaceId, homepage: .object(objectId: details.id))
        AnytypeAnalytics.instance().logChangeSpaceDashboard()
        if let homeData = details.screenData().homeSlotValue {
            onHomepageSet?(homeData)
        }
        dismiss = true
    }
}
