import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class HomePagePickerViewModel {

    @ObservationIgnored @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @ObservationIgnored @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol

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
        let homepage = spaceView?.homepage ?? ""
        self.currentObjectId = homepage.isEmpty || homepage == "widgets" ? nil : homepage
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
        try await workspaceService.setHomepage(spaceId: spaceId, homepage: "widgets")
        try await onFinish()
        dismiss = true
    }

    func onObjectSelected(_ details: ObjectDetails) async throws {
        try await workspaceService.setHomepage(spaceId: spaceId, homepage: details.id)
        try await onFinish()
        dismiss = true
    }
}
