import Foundation
import Services
import Combine
import Collections
import AnytypeCore

@MainActor
final class WidgetObjectListRecentViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let spaceId: String
    private let type: RecentWidgetType
    private let dateFormatter = AnytypeRelativeDateTimeFormatter()
    
    @Injected(\.recentSubscriptionService)
    private var recentSubscriptionService: any RecentSubscriptionServiceProtocol
    
    
    // MARK: - State
    
    var title: String { type.title }
    let emptyStateData = WidgetObjectListEmptyStateData(
        title: Loc.EmptyView.Default.title,
        subtitle: Loc.EmptyView.Default.subtitle
    )
    var editorScreenData: EditorScreenData { type.editorScreenData(spaceId: spaceId) }
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: false)
    
    private var details: [ObjectDetails] = []
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(spaceId: String, type: RecentWidgetType) {
        self.spaceId = spaceId
        self.type = type
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        Task {
            await recentSubscriptionService.startSubscription(spaceId: spaceId, type: type, objectLimit: nil) { [weak self] details in
                self?.details = details
                self?.updateRows()
            }
        }
    }
    
    func onDisappear() {
        Task {
            await recentSubscriptionService.stopSubscription()
        }
    }
    
    func subtitle(for details: ObjectDetails) -> String? {
        return details.objectType.displayName
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
