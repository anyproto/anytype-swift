import Foundation
import Services
import Combine

final class WidgetObjectListCollectionsViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let subscriptionService: CollectionsSubscriptionServiceProtocol
    
    // MARK: - State
    
    let title = Loc.collections
    let editorViewType: EditorViewType = .collections
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: false)
    
    private var details: [ObjectDetails] = [] {
        didSet { rowDetails = [WidgetObjectListDetailsData(details: details)] }
    }
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(subscriptionService: CollectionsSubscriptionServiceProtocol) {
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        subscriptionService.startSubscription(objectLimit: nil, update: { [weak self] _, update in
            self?.details.applySubscriptionUpdate(update)
        })
    }
    
    func onDisappear() {
        subscriptionService.stopSubscription()
    }
}
