import SwiftUI
import Services

@MainActor
final class SharingExtensionShareToViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    
    private let data: SharingExtensionShareToData
    
    @Published var title: String = ""
    @Published var searchText: String = ""
    @Published var searchData: [ObjectSearchData] = []
    
    init(data: SharingExtensionShareToData) {
        self.data = data
        self.title = workspacesStorage.spaceView(spaceId: data.spaceId)?.title ?? ""
    }
    
    func search() async {
        do {
            let result = try await searchService.searchObjectsWithLayouts(
                text: searchText,
                layouts: DetailsLayout.supportedForSharingExtension,
                excludedIds: [],
                spaceId: data.spaceId
            )
            searchData = result.compactMap { ObjectSearchData(details: $0) }
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            searchData = []
        }
    }
}
