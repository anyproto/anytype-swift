import SwiftUI
import Services

@MainActor
final class SharingExtensionShareToViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    
    private let data: SharingExtensionShareToData
    
    private var details: [ObjectDetails] = []
    
    @Published var title: String = ""
    @Published var searchText: String = ""
    @Published var rows: [SharingExtensionsShareRowData] = []
    @Published var selectedObjectIds: Set<String> = []
    
    @Published var comment: String = ""
    let commentLimit = ChatMessageGlobalLimits.textLimit
    let commentWarningLimit = ChatMessageGlobalLimits.textLimitWarning
    
    init(data: SharingExtensionShareToData) {
        self.data = data
        self.title = workspacesStorage.spaceView(spaceId: data.spaceId)?.title ?? ""
    }
    
    func search() async {
        
        // Can call each times. Method is optimized
        await activeSpaceManager.prepareSpaceForPreview(spaceId: data.spaceId)
        
        do {
            let result = try await searchService.searchObjectsWithLayouts(
                text: searchText,
                layouts: DetailsLayout.supportedForSharingExtension,
                excludedIds: [],
                spaceId: data.spaceId
            )
            details = result
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            details = []
        }
        updateRows()
    }
    
    func onTapCell(data: SharingExtensionsShareRowData) {
        if selectedObjectIds.contains(data.objectId) {
            selectedObjectIds.remove(data.objectId)
        } else {
            selectedObjectIds.insert(data.objectId)
        }
        updateRows()
    }
    
    func onTapSend() async throws {
        // TODO: Implement
    }
    
    // MARK: - Private
    
    private func updateRows() {
        rows = details.compactMap { details in
            SharingExtensionsShareRowData(
                objectId: details.id,
                icon: details.objectIconImage,
                title: details.pluralTitle,
                subtitle: details.description,
                selected: selectedObjectIds.contains(details.id)
            )
        }
    }
}
