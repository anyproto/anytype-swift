import Foundation
import Services
import AnytypeCore
import Combine

@MainActor
@Observable
final class HomePagePickerViewModel {

    @ObservationIgnored @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @ObservationIgnored @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol

    var searchText = ""
    var objects: [ObjectDetails] = []
    var dismiss = false

    @ObservationIgnored
    private let onFinish: () async throws -> Void
    private let spaceId: String
    private let spaceUxType: SpaceUxType?
    let currentObjectId: String?
    let isChatSpace: Bool

    init(spaceId: String, onFinish: @escaping () async throws -> Void = {}) {
        self.spaceId = spaceId
        self.onFinish = onFinish
        let spaceView = Container.shared.spaceViewsStorage().spaceView(spaceId: spaceId)
        self.spaceUxType = spaceView?.uxType
        self.isChatSpace = spaceView?.initialScreenIsChat ?? false
        self.currentObjectId = Container.shared.userDefaultsStorage().homeObjectId(spaceId: spaceId)
    }

    var defaultOptionTitle: String {
        isChatSpace ? Loc.chat : Loc.SpaceSettings.HomePage.widgets
    }

    func search() async {
        do {
            try await Task.sleep(for: .milliseconds(300))
            let layouts: [DetailsLayout] = DetailsLayout.visibleLayoutsWithFiles(spaceUxType: spaceUxType)
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

    func onWidgetsSelected() async throws {
        userDefaults.setHomeObjectId(spaceId: spaceId, objectId: nil)
        try await onFinish()
        dismiss = true
    }

    func onObjectSelected(_ details: ObjectDetails) async throws {
        userDefaults.setHomeObjectId(spaceId: spaceId, objectId: details.id)
        try await onFinish()
        dismiss = true
    }
}
