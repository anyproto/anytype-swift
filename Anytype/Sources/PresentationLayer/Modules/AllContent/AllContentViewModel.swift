import Foundation
import Services

@MainActor
protocol AllContentModuleOutput: AnyObject {
    func onObjectSelected(screenData: EditorScreenData)
}

@MainActor
final class AllContentViewModel: ObservableObject {

    @Published var rows: [WidgetObjectListRowModel] = []
    @Published var state = AllContentState()
    @Published var searchText = ""
    
    @Injected(\.allContentSubscriptionService)
    private var allContentSubscriptionService: any AllContentSubscriptionServiceProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    
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
                self?.updateRows(with: details)
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
    
    private func updateRows(with details: [ObjectDetails]) {
        rows = details.map { details in
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
    }
}
