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
    private var objectsToLoad = 0
    
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
            limit: state.limit,
            update: { [weak self] details, objectsToLoad in
                self?.details = details
                self?.objectsToLoad = objectsToLoad
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
    
    func typeChanged(_ type: AllContentType) {
        state.type = type
    }
    
    func binTapped() {
        output?.onObjectSelected(screenData: .bin(spaceId: spaceId))
    }
    
    func onDisappear() {
        stopSubscription()
    }
    
    func onAppearLastRow(_ id: String) {
        guard objectsToLoad > 0, details.last?.id == id else { return }
        objectsToLoad = 0
        state.updateLimit()
    }
    
    private func stopSubscription() {
        Task {
            await allContentSubscriptionService.stopSubscription()
        }
    }
    
    private func updateRows() {
        if state.sort.relation.canGroupByDate {
            let today = Date()
            let dict = OrderedDictionary(
                grouping: details,
                by: { dateFormatter.localizedString(for: sortValue(for: $0) ?? today, relativeTo: today) }
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
