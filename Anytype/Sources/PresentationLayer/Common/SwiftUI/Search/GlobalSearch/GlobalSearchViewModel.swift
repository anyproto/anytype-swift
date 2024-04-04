import Services
import Combine

@MainActor
final class GlobalSearchViewModel: ObservableObject {
    
    @Injected(\.searchService)
    private var searchService: SearchServiceProtocol
    private let data: GlobalSearchModuleData
    
    @Published var searchText = ""
    @Published var searchData: [GlobalSearchDataSection] = []
    
    init(data: GlobalSearchModuleData) {
        self.data = data
    }
    
    func search() async {
        do {
            let result = try await searchService.search(text: searchText, spaceId: data.spaceId)
            
            let objectsSearchData = result.compactMap { GlobalSearchData(details: $0) }
            
            guard objectsSearchData.isNotEmpty else {
                searchData = []
                return
            }
            
            searchData = [GlobalSearchDataSection(searchData: objectsSearchData)]
            
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            searchData = []
        }
    }
    
    func onSelect(searchData: GlobalSearchData) {
        data.onSelect(searchData.editorScreenData)
    }
    
    func clear() {
        
    }
}
