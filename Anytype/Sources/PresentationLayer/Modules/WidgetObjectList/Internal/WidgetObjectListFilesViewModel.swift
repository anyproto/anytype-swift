import Foundation
import Services
import Combine

@MainActor
final class WidgetObjectListFilesViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let subscriptionService: FilesSubscriptionServiceProtocol
    private let formatter = ByteCountFormatter.fileFormatter
    // MARK: - State
    
    let title = Loc.FilesList.title
    let editorScreenData: EditorScreenData = .favorites // Is not used
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .editOnly
    let availableMenuItems: [WidgetObjectListMenuItem] = [.forceDelete]
    
    private var details: [ObjectDetails] = [] {
        didSet { rowDetails = [WidgetObjectListDetailsData(details: details)] }
    }
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(subscriptionService: FilesSubscriptionServiceProtocol) {
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsStorageManager()
        Task {
            await subscriptionService.startSubscription(syncStatus: .synced, objectLimit: nil, update: { [weak self] details in
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
