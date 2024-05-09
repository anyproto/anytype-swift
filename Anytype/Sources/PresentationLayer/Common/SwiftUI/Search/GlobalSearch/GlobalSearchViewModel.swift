import Services
import Combine

@MainActor
final class GlobalSearchViewModel: ObservableObject {
    
    @Injected(\.searchWithMetaService)
    private var searchWithMetaService: SearchWithMetaServiceProtocol
    @Injected(\.globalSearchDataBuilder)
    private var globalSearchDataBuilder: GlobalSearchDataBuilderProtocol
    
    private let moduleData: GlobalSearchModuleData
    
    @Published var state = GlobalSearchState()
    @Published var searchData: [GlobalSearchDataSection] = []
    
    init(data: GlobalSearchModuleData) {
        self.moduleData = data
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSearch()
    }
    
    func search() async {
        do {
            let result: [SearchResultWithMeta]
            switch state.mode {
            case .default:
                result = try await searchWithMetaService.search(text: state.searchText, spaceId: moduleData.spaceId)
            case .filtered(_, let limitObjectIds):
                result = try await searchWithMetaService.search(text: state.searchText, limitObjectIds: limitObjectIds)
            }
            
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
    
    func onSelect(searchData: GlobalSearchData) {
        AnytypeAnalytics.instance().logSearchResult(spaceId: moduleData.spaceId)
        moduleData.onSelect(searchData.editorScreenData)
    }
    
    func showBacklinks(_ data: GlobalSearchData) {
        state = GlobalSearchState(
            searchText: "",
            mode: .filtered(name: data.title, limitObjectIds: data.backlinks)
        )
    }
    
    func clear() {
        state = GlobalSearchState(
            searchText: "",
            mode: .default
        )
    }
    
    private func sectionConfig() -> GlobalSearchDataSection.SectionConfig? {
        switch state.mode {
        case .default:
            return nil
        case .filtered(let name, _):
            return GlobalSearchDataSection.SectionConfig(
                title: Loc.Search.Backlinks.Header.title(name),
                buttonTitle: Loc.clear
            )
        }
    }
}
