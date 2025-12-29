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

    private let spaceId: String
    let currentObjectId: String?

    init(spaceId: String) {
        self.spaceId = spaceId
        self.currentObjectId = Container.shared.userDefaultsStorage().homeObjectId(spaceId: spaceId)
    }

    func search() async {
        do {
            let layouts: [DetailsLayout] = DetailsLayout.visibleLayoutsWithFiles(spaceUxType: .data)
            objects = try await searchService.searchObjectsWithLayouts(
                text: searchText,
                layouts: layouts,
                excludedIds: [],
                spaceId: spaceId
            ).filter { !$0.isArchived && !$0.isDeleted }
        } catch is CancellationError {
            // Ignore
        } catch {
            objects = []
        }
    }

    func onWidgetsSelected() {
        userDefaults.setHomeObjectId(spaceId: spaceId, objectId: nil)
        dismiss = true
    }

    func onObjectSelected(_ details: ObjectDetails) {
        userDefaults.setHomeObjectId(spaceId: spaceId, objectId: details.id)
        dismiss = true
    }
}
