import Foundation
import Services
import OrderedCollections

@MainActor
protocol AllContentModuleOutput: AnyObject {
    func onObjectSelected(screenData: EditorScreenData)
}

@MainActor
final class AllContentViewModel: ObservableObject {

    private var details = [ObjectDetails]()
    @Published var sections = [ListSectionData<String?, WidgetObjectListRowModel>]()
    @Published var state = AllContentState()
    @Published var searchText = ""
    
    @Injected(\.allContentSubscriptionService)
    private var allContentSubscriptionService: any AllContentSubscriptionServiceProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    
    private let dateFormatter = AnytypeRelativeDateTimeFormatter()
    
    private let spaceId: String
    private weak var output: (any AllContentModuleOutput)?
    
    init(spaceId: String, output: (any AllContentModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
    }
    
    func restartSubscription() async {
        await allContentSubscriptionService.startSubscription(
            spaceId: spaceId,
            type: state.type,
            sort: state.sort,
            onlyUnlinked: state.mode == .unlinked,
            limitedObjectsIds: state.limitedObjectsIds,
            update: { [weak self] details in
                self?.details = details
                self?.updateRows()
            }
        )
    }
    
    func search() async {
        do {
            guard searchText.isNotEmpty else {
                state.limitedObjectsIds = nil
                return
            }
            
            try await Task.sleep(seconds: 0.3)
            
            state.limitedObjectsIds = try await searchService.searchAll(text: searchText, spaceId: spaceId).map { $0.id }
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            state.limitedObjectsIds = nil
        }
    }
    
    func modeChanged(_ mode: AllContentMode) {
        state.mode = mode
    }
    
    func typeChanged(_ type: AllContentType) {
        state.type = type
    }
    
    func sortRelationChanged(_ sortRelation: AllContentSort.Relation) {
        guard state.sort.relation != sortRelation else { return }
        state.sort = AllContentSort(relation: sortRelation)
    }
    
    func sortTypeChanged(_ sortType: DataviewSort.TypeEnum) {
        guard state.sort.type != sortType else { return }
        state.sort.type = sortType
    }
    
    func binTapped() {
        output?.onObjectSelected(screenData: .bin(spaceId: spaceId))
    }
    
    func onDisappear() {
        stopSubscription()
    }
    
    private func stopSubscription() {
        Task {
            await allContentSubscriptionService.stopSubscription()
        }
    }
    
    private func updateRows() {
        if state.sort.relation.canGroupByDate {
            let toDate = Date()
            let dict = OrderedDictionary(
                grouping: details,
                by: { dateFormatter.localizedString(for: sortValue(for: $0) ?? toDate, relativeTo: toDate) }
            )
            sections = dict.map { (key, details) in
                listSectionData(title: key, details: details)
            }
        } else {
            sections = [listSectionData(title: nil, details: details)]
        }
    }
    
    private func listSectionData(title: String?, details: [ObjectDetails]) -> ListSectionData<String?, WidgetObjectListRowModel> {
        ListSectionData(
            id: title ?? UUID().uuidString,
            data: title,
            rows: details.map { details in
                WidgetObjectListRowModel(
                    objectId: details.id,
                    icon: details.objectIconImage,
                    title: details.title,
                    description: details.subtitle,
                    subtitle: details.objectType.name,
                    isChecked: false,
                    menu: [],
                    onTap: { [weak self] in
                        self?.output?.onObjectSelected(screenData: details.editorScreenData())
                    },
                    onCheckboxTap: nil
                )
            }
        )
    }
    
    private func sortValue(for details: ObjectDetails) -> Date? {
        switch state.sort.relation {
        case .dateUpdated:
            return details.lastModifiedDate
        case .dateCreated:
            return details.createdDate
        case .name:
            return nil
        }
    }
}
