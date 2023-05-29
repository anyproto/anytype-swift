import Foundation
import BlocksModels
import Combine
import Collections

final class WidgetObjectListRecentViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let recentSubscriptionService: RecentSubscriptionServiceProtocol
    private let dateFormatter = AnytypeRelativeDateTimeFormatter()
    
    // MARK: - State
    
    let title = Loc.recent
    let editorViewType: EditorViewType = .recent
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: false)
    
    private var details: [ObjectDetails] = []
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(recentSubscriptionService: RecentSubscriptionServiceProtocol) {
        self.recentSubscriptionService = recentSubscriptionService
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        recentSubscriptionService.startSubscription(objectLimit: nil, update: { [weak self] _, update in
            self?.details.applySubscriptionUpdate(update)
            self?.updateRows()
        })
    }
    
    func onDisappear() {
        recentSubscriptionService.stopSubscription()
    }
    
    func subtitle(for details: ObjectDetails) -> String? {
        return details.subtitle
    }
    
    // MARK: - Private
    
    private func updateRows() {
        let toDate = Date()
        let dict = OrderedDictionary(
            grouping: details,
            by: { dateFormatter.localizedString(for: $0.lastOpenedDate ?? toDate, relativeTo: toDate) }
        )
        rowDetails = dict.map { WidgetObjectListDetailsData(id: $0.key, title: $0.key, details: $0.value) }
    }
}
