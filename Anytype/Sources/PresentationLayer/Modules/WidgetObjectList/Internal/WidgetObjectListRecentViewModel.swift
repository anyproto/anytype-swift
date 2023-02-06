import Foundation
import BlocksModels
import Combine

final class WidgetObjectListRecentViewModel: ObservableObject, WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let recentSubscriptionService: RecentSubscriptionServiceProtocol
    
    // MARK: - State
    
    var title = Loc.recent
    var editorViewType: EditorViewType = .recent
    var rowDetailsPublisher: AnyPublisher<[ObjectDetails], Never> {
        $rowDetails.eraseToAnyPublisher()
    }
    
    @Published private var rowDetails: [ObjectDetails] = []
    
    init(recentSubscriptionService: RecentSubscriptionServiceProtocol) {
        self.recentSubscriptionService = recentSubscriptionService
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        recentSubscriptionService.startSubscription(objectLimit: nil, update: { [weak self] _, update in
            self?.rowDetails.applySubscriptionUpdate(update)
        })
    }
    
    func onDisappear() {
        recentSubscriptionService.stopSubscription()
    }
}
