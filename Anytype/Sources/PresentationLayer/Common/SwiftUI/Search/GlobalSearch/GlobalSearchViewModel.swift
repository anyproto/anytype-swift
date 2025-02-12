import Services
import Combine

@MainActor
final class GlobalSearchViewModel: ObservableObject {
    
    @Injected(\.searchWithMetaService)
    private var searchWithMetaService: any SearchWithMetaServiceProtocol
    @Injected(\.globalSearchDataBuilder)
    private var globalSearchDataBuilder: any GlobalSearchDataBuilderProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectCreationService: any DefaultObjectCreationServiceProtocol
    @Injected(\.globalSearchSavedStatesService)
    private var globalSearchSavedStatesService: any GlobalSearchSavedStatesServiceProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    
    private let moduleData: GlobalSearchModuleData
    
    @Published var state = GlobalSearchState()
    @Published var searchData: [GlobalSearchDataSection] = []
    @Published var dismiss = false
    
    var isInitial = true
    private var modeChanged = false
    
    init(data: GlobalSearchModuleData) {
        self.moduleData = data
        self.restoreState()
    }
    
    func search() async {
        do {
            if needDelay() {
                try await Task.sleep(seconds: 0.3)
            }
            
            let result: [SearchResultWithMeta]
            switch state.mode {
            case .default:
                result = try await searchWithMetaService.search(text: state.searchText, spaceId: moduleData.spaceId)
            case .filtered(let data):
                result = try await searchWithMetaService.search(text: state.searchText, spaceId: moduleData.spaceId, limitObjectIds: data.limitObjectIds)
            }
            
            updateInitialStateIfNeeded()
            
            let objectsSearchData = result.compactMap { result in
                globalSearchDataBuilder.buildData(with: result, spaceId: moduleData.spaceId)
            }
            
            guard objectsSearchData.isNotEmpty else {
                searchData = []
                return
            }
            
            searchData = [
                GlobalSearchDataSection(
                    searchData: objectsSearchData,
                    sectionConfig: sectionConfig()
                )
            ]
            
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            searchData = []
        }
    }
    
    func onSearchTextChanged() {
        storeState()
        AnytypeAnalytics.instance().logSearchInput(spaceId: moduleData.spaceId)
    }
    
    func onKeyboardButtonTap() {
        guard let firstObject = searchData.first?.searchData.first else { return }
        onSelect(searchData: firstObject)
    }
    
    func onSelect(searchData: GlobalSearchData) {
        AnytypeAnalytics.instance().logSearchResult(spaceId: moduleData.spaceId)
        dismiss.toggle()
        moduleData.onSelect(searchData.editorScreenData)
    }
    
    func showRelatedObjects(_ data: GlobalSearchData) {
        let name = String(data.title.characters)
        state = GlobalSearchState(
            searchText: "",
            mode: .filtered(FilteredData(id: data.id, name: name, limitObjectIds: data.relatedLinks))
        )
        storeState()
        modeChanged = true
        AnytypeAnalytics.instance().logSearchBacklink(spaceId: moduleData.spaceId, type: .empty)
    }
    
    func clear() {
        state = GlobalSearchState(
            searchText: "",
            mode: .default
        )
        storeState()
        modeChanged = true
    }
    
    func createObject() {
        Task {            
            let objectDetails = try? await defaultObjectCreationService.createDefaultObject(
                name: state.searchText,
                shouldDeleteEmptyObject: false,
                spaceId: moduleData.spaceId
            )
            
            guard let objectDetails else { return }
            
            AnytypeAnalytics.instance().logCreateObject(objectType: objectDetails.analyticsType, spaceId: objectDetails.spaceId, route: .search)
            
            dismiss.toggle()
            moduleData.onSelect(objectDetails.screenData())
        }
    }
    
    func sectionConfig() -> GlobalSearchDataSection.SectionConfig? {
        switch state.mode {
        case .default:
            return nil
        case .filtered(let data):
            return GlobalSearchDataSection.SectionConfig(
                title: Loc.Search.Links.Header.title(data.name),
                buttonTitle: Loc.clear
            )
        }
    }
    
    private func updateInitialStateIfNeeded() {
        guard isInitial else { return }
        isInitial = false
    }
    
    private func needDelay() -> Bool {
        guard modeChanged || isInitial else { return true }
        modeChanged = false
        return false
    }
    
    private func restoreState() {
        let restoredState = globalSearchSavedStatesService.restoreState(for: moduleData.spaceId)
        guard let restoredState else {
            AnytypeAnalytics.instance().logScreenSearch(spaceId: moduleData.spaceId, type: .empty)
            return
        }
        switch restoredState.mode {
        case .default:
            state = restoredState
            if restoredState.searchText.isNotEmpty {
                AnytypeAnalytics.instance().logScreenSearch(spaceId: moduleData.spaceId, type: .saved)
            }
        case .filtered(let data):
            Task {
                let details = try await searchService.search(text: "", spaceId: moduleData.spaceId, limitObjectIds: [data.id]).first
                guard let details else { return }
                state = GlobalSearchState(
                    searchText: restoredState.searchText,
                    mode: .filtered(FilteredData(
                        id: details.id,
                        name: details.title,
                        limitObjectIds: details.backlinks + details.links
                    ))
                )
                AnytypeAnalytics.instance().logSearchBacklink(spaceId: moduleData.spaceId, type: .saved)
            }
        }
    }
    
    private func storeState() {
        globalSearchSavedStatesService.storeState(state, spaceId: moduleData.spaceId)
    }
}
