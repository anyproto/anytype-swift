import Services
import Combine
import Foundation
import OrderedCollections
import AnytypeCore

@MainActor
final class GlobalSearchViewModel: ObservableObject {
    
    @Injected(\.searchWithMetaService)
    private var searchWithMetaService: any SearchWithMetaServiceProtocol
    @Injected(\.globalSearchDataBuilder)
    private var globalSearchDataBuilder: any GlobalSearchDataBuilderProtocol
    @Injected(\.globalSearchSavedStatesService)
    private var globalSearchSavedStatesService: any GlobalSearchSavedStatesServiceProtocol
    
    private let moduleData: GlobalSearchModuleData
    
    private let dateFormatter = AnytypeRelativeDateTimeFormatter()
    
    @Published var state = GlobalSearchState()
    @Published var sections = [ListSectionData<String?, GlobalSearchData>]()
    @Published var dismiss = false
    
    private var sectionChanged = false
    var isInitial = true
    
    init(data: GlobalSearchModuleData) {
        self.moduleData = data
        self.restoreState()
    }
    
    func search() async {
        do {
            if needDelay() {
                try await Task.sleep(seconds: 0.3)
            }

            let result = try await searchWithMetaService.search(
                text: state.searchText,
                spaceId: moduleData.spaceId,
                layouts: buildLayouts(),
                sorts: buildSorts()
            )
            
            updateInitialStateIfNeeded()
            updateSections(result: result)
            
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            sections = []
        }
    }
    
    func onSectionChanged(_ section: ObjectTypeSection) {
        sectionChanged = true
        state.section = section
        storeState()
    }
    
    func onSearchTextChanged() {
        storeState()
        AnytypeAnalytics.instance().logSearchInput(spaceId: moduleData.spaceId)
    }
    
    func onKeyboardButtonTap() {
        guard let firstObject = sections.first?.rows.first else { return }
        onSelect(searchData: firstObject)
    }
    
    func onSelect(searchData: GlobalSearchData) {
        AnytypeAnalytics.instance().logSearchResult(spaceId: moduleData.spaceId)
        dismiss.toggle()
        moduleData.onSelect(searchData.editorScreenData)
    }
    
    private func updateSections(result: [SearchResultWithMeta]) {
        guard result.isNotEmpty else {
            sections = []
            return
        }
        
        guard state.shouldGroupResults else {
            sections = [listSectionData(title: nil, result: result)]
            return
        }
        
        let today = Date()
        let dict = OrderedDictionary(
            grouping: result,
            by: { dateFormatter.localizedString(for: sortValue(for: $0.objectDetails) ?? today, relativeTo: today) }
        )
        
        sections = dict.map { (key, result) in
            listSectionData(title: key, result: result)
        }
    }
    
    private func updateInitialStateIfNeeded() {
        guard isInitial else { return }
        isInitial = false
    }
    
    private func needDelay() -> Bool {
        guard sectionChanged || isInitial else { return true }
        sectionChanged = false
        return false
    }
    
    private func restoreState() {
        let restoredState = globalSearchSavedStatesService.restoreState(for: moduleData.spaceId)
        guard let restoredState else {
            AnytypeAnalytics.instance().logScreenSearch(spaceId: moduleData.spaceId, type: .empty)
            return
        }
        state = restoredState
        if restoredState.searchText.isNotEmpty {
            AnytypeAnalytics.instance().logScreenSearch(spaceId: moduleData.spaceId, type: .saved)
        }
    }
    
    private func storeState() {
        globalSearchSavedStatesService.storeState(state, spaceId: moduleData.spaceId)
    }
    
    private func listSectionData(title: String?, result: [SearchResultWithMeta]) -> ListSectionData<String?, GlobalSearchData> {
        ListSectionData(
            id: title ?? UUID().uuidString,
            data: title,
            rows: result.compactMap { result in
                globalSearchDataBuilder.buildData(with: result, spaceId: moduleData.spaceId)
            }
        )
    }
    
    private func buildLayouts() -> [DetailsLayout] {
        .builder {
            if state.searchText.isEmpty {
                state.section.supportedLayouts.filter { $0 != .participant }
            } else {
                state.section.supportedLayouts
            }
        }
    }
    
    private func buildSorts() -> [DataviewSort] {
        .builder {
            if state.searchText.isEmpty {
                state.sort.asDataviewSort()
            } else {
                SearchHelper.sort(
                    relation: BundledRelationKey.lastOpenedDate,
                    type: .desc
                )
            }
        }
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
