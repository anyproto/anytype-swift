import Foundation
import Services
import Combine

@MainActor
final class WidgetObjectListCollectionsViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let spaceId: String
    @Injected(\.collectionsSubscriptionService)
    private var subscriptionService: any CollectionsSubscriptionServiceProtocol
    
    // MARK: - State
    
    let title = Loc.collections
    let emptyStateData = WidgetObjectListEmptyStateData(
        title: Loc.EmptyView.Default.title,
        subtitle: Loc.EmptyView.Default.subtitle
    )
    let editorScreenData: EditorScreenData
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: false)
    
    private var details: [ObjectDetails] = [] {
        didSet { rowDetails = [WidgetObjectListDetailsData(details: details)] }
    }
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.editorScreenData = .collections(spaceId: spaceId)
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        Task {
            await subscriptionService.startSubscription(spaceId: spaceId, objectLimit: nil) { [weak self] details in
                guard let self else { return }
                rowDetails = [WidgetObjectListDetailsData(details: details)]
            }
        }
    }
    
    func onDisappear() {
        Task {
            await subscriptionService.stopSubscription()
        }
    }
}
