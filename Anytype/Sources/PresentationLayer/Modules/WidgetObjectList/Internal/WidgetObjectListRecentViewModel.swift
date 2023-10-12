import Foundation
import Services
import Combine
import Collections
import AnytypeCore

final class WidgetObjectListRecentViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let type: RecentWidgetType
    private let recentSubscriptionService: RecentSubscriptionServiceProtocol
    private let dateFormatter = AnytypeRelativeDateTimeFormatter()
    
    // MARK: - State
    
    var title: String { type.title }
    var editorScreenData: EditorScreenData { type.editorScreenData }
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: false)
    
    private var details: [ObjectDetails] = []
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(type: RecentWidgetType, recentSubscriptionService: RecentSubscriptionServiceProtocol) {
        self.type = type
        self.recentSubscriptionService = recentSubscriptionService
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        recentSubscriptionService.startSubscription(type: type, objectLimit: nil, update: { [weak self] _, update in
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
            by: { dateFormatter.localizedString(for: sortValue(for: $0) ?? toDate, relativeTo: toDate) }
        )
        rowDetails = dict.map { WidgetObjectListDetailsData(id: $0.key, title: $0.key, details: $0.value) }
    }
    
    private func sortValue(for details: ObjectDetails) -> Date? {
        switch type {
        case .recentEdit:
            return details.lastModifiedDate
        case .recentOpen:
            return details.lastOpenedDate
        }
    }
}
