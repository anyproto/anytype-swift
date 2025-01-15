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
    
    private let moduleData: GlobalSearchModuleData
    
    @Published var state = GlobalSearchState()
    @Published var searchData: [GlobalSearchDataSection] = []
    @Published var dismiss = false
    
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
            
            let result: [SearchResultWithMeta]
            switch state.mode {
            case .default:
                result = try await searchWithMetaService.search(text: state.searchText, spaceId: moduleData.spaceId)
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
        return nil
    }
    
    private func updateInitialStateIfNeeded() {
        guard isInitial else { return }
        isInitial = false
    }
    
    private func needDelay() -> Bool {
        !isInitial
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
        }
    }
    
    private func storeState() {
        globalSearchSavedStatesService.storeState(state, spaceId: moduleData.spaceId)
    }
}
