import Foundation
import Services
import Combine

@MainActor
final class WidgetObjectListSetsViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let spaceId: String
    @Injected(\.setsSubscriptionService)
    private var setsSubscriptionService: any SetsSubscriptionServiceProtocol
    
    // MARK: - State
    
    let title = Loc.sets
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
        self.editorScreenData = .sets(spaceId: spaceId)
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        Task {
            await setsSubscriptionService.startSubscription(spaceId: spaceId, objectLimit: nil) { [weak self] details in
                self?.details = details
            }
        }
    }
    
    func onDisappear() {
        Task {
            await setsSubscriptionService.stopSubscription()
        }
    }
}
