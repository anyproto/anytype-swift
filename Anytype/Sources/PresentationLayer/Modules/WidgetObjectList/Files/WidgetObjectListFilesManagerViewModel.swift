import Foundation
import Services
import Combine

@MainActor
final class WidgetObjectListFilesManagerViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    @Injected(\.filesSubscriptionManager)
    private var subscriptionService: any FilesSubscriptionServiceProtocol
    private let formatter = ByteCountFormatter.fileFormatter
    private let spaceId: String
    
    // MARK: - State
    
    let title = Loc.FilesList.title
    let emptyStateData = WidgetObjectListEmptyStateData(
        title: Loc.EmptyView.Default.title,
        subtitle: Loc.EmptyView.Default.subtitle
    )
    let editorScreenData: EditorScreenData = .favorites(homeObjectId: "", spaceId: "") // Is not used
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .editOnly
    let availableMenuItems: [WidgetObjectListMenuItem] = [.forceDelete]
    
    private var details: [ObjectDetails] = [] {
        didSet { rowDetails = [WidgetObjectListDetailsData(details: details)] }
    }
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceStorageManager()
        Task {
            await subscriptionService.startSubscription(syncStatus: .synced, spaceId: spaceId, objectLimit: nil, update: { [weak self] details in
                self?.details = details
            })
        }
    }
    
    func onDisappear() {
        Task {
            await subscriptionService.stopSubscription()
        }
    }
    
    func subtitle(for details: ObjectDetails) -> String? {
        return details.sizeInBytes.map { formatter.string(fromByteCount: Int64($0)) }
    }
}
