import Foundation
import Services
import Combine

final class WidgetObjectListFilesViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let subscriptionService: FilesSubscriptionServiceProtocol
    
    // MARK: - State
    
    let title = Loc.FilesList.title
    let editorScreenData: EditorScreenData = .favorites // Is not used
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .editOnly
    let availableMenuItems: [WidgetObjectListMenuItem] = [.forceDelete]
    let forceDeleteTitle: String = Loc.FilesList.ForceDelete.title
    
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
        subscriptionService.startSubscription(syncStatus: .synced, objectLimit: nil, update: { [weak self] _, update in
            self?.details.applySubscriptionUpdate(update)
        })
    }
    
    func onDisappear() {
        subscriptionService.stopSubscription()
    }
    
    func subtitle(for details: ObjectDetails) -> String? {
        return details.sizeInBytes.map { FileSizeConverter.convert(size: Int64($0)) }
    }
}
