import Foundation
import Services
import Combine
import Collections
import AnytypeCore

@MainActor
final class WidgetObjectListAllContentViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let spaceId: String
    private let type: AllObjectWidgetType
    private let dateFormatter = AnytypeRelativeDateTimeFormatter()
    
    @Injected(\.allContentSubscriptionService)
    private var allContentSubscriptionService: any AllContentSubscriptionServiceProtocol
    
    // MARK: - State
    
    var title: String { type.name }
    let emptyStateData = WidgetObjectListEmptyStateData(
        title: Loc.EmptyView.Default.title,
        subtitle: Loc.EmptyView.Default.subtitle
    )
    var editorScreenData: EditorScreenData { type.editorScreenData(spaceId: spaceId) }
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: false)
    
    private var details: [ObjectDetails] = []
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(spaceId: String, type: AllObjectWidgetType) {
        self.spaceId = spaceId
        self.type = type
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        Task {
            await allContentSubscriptionService.startSubscription(
                spaceId: spaceId,
                section: type.typeSection,
                sort: ObjectSort(relation: .dateUpdated),
                onlyUnlinked: false,
                limitedObjectsIds: nil,
                limit: 100,
                update: { [weak self] details, _ in
                    self?.details = details
                    self?.updateRows()
                }
            )
        }
    }
    
    func onDisappear() {
        Task {
            await allContentSubscriptionService.stopSubscription()
        }
    }
    
    func subtitle(for details: ObjectDetails) -> String? {
        return details.objectType.name
    }
    
    // MARK: - Private
    
    private func updateRows() {
        let toDate = Date()
        let dict = OrderedDictionary(
            grouping: details,
            by: { dateFormatter.localizedString(for: $0.lastModifiedDate ?? toDate, relativeTo: toDate) }
        )
        rowDetails = dict.map { WidgetObjectListDetailsData(id: $0.key, title: $0.key, details: $0.value) }
    }
}
