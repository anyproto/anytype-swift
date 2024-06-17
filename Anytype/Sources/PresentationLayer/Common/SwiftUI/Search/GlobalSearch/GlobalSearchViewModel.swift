import Services
import Combine

@MainActor
final class GlobalSearchViewModel: ObservableObject {
    
    @Injected(\.searchWithMetaService)
    private var searchWithMetaService: SearchWithMetaServiceProtocol
    @Injected(\.globalSearchDataBuilder)
    private var globalSearchDataBuilder: GlobalSearchDataBuilderProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectCreationService: DefaultObjectCreationServiceProtocol
    
    private let moduleData: GlobalSearchModuleData
    
    @Published var state = GlobalSearchState()
    @Published var searchData: [GlobalSearchDataSection] = []
    @Published var dismiss = false
    private var modeChanged = false
    
    init(data: GlobalSearchModuleData) {
        self.moduleData = data
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSearch()
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
            case .filtered(_, let limitObjectIds):
                result = try await searchWithMetaService.search(text: state.searchText, limitObjectIds: limitObjectIds)
            }
            
            updateInitialStateIfNeeded()
            
            let objectsSearchData = result.compactMap { [weak self] result in
                self?.globalSearchDataBuilder.buildData(with: result)
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
        state = GlobalSearchState(
            searchText: "",
            mode: .filtered(name: data.title, limitObjectIds: data.relatedLinks)
        )
        modeChanged = true
        AnytypeAnalytics.instance().logSearchBacklink(spaceId: moduleData.spaceId)
    }
    
    func clear() {
        state = GlobalSearchState(
            searchText: "",
            mode: .default
        )
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
            moduleData.onSelect(objectDetails.editorScreenData())
        }
    }
    
    func sectionConfig() -> GlobalSearchDataSection.SectionConfig? {
        switch state.mode {
        case .default:
            return nil
        case .filtered(let name, _):
            return GlobalSearchDataSection.SectionConfig(
                title: Loc.Search.Links.Header.title(name),
                buttonTitle: Loc.clear
            )
        }
    }
    
    private func updateInitialStateIfNeeded() {
        guard state.isInitial else { return }
        state.isInitial = false
    }
    
    private func needDelay() -> Bool {
        guard modeChanged || state.isInitial else { return true }
        modeChanged = false
        return false
    }
}
