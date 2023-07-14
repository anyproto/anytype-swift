import SwiftUI
import Services
import Combine

/// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=6455%3A4097
final class ObjectSearchViewModel: SearchViewModelProtocol {
    
    @Published var searchData: [SearchDataSection<ObjectSearchData>] = []
    
    var onSelect: (ObjectSearchData) -> ()
    var onDismiss: () -> () = {}

    let placeholder: String = Loc.search
    
    private let searchService: SearchServiceProtocol
    
    private var searchTask: AnyCancellable?
    
    init(searchService: SearchServiceProtocol, onSelect: @escaping (SearchDataType) -> ()) {
        self.searchService = searchService
        self.onSelect = onSelect
    }
    
    func search(text: String) {
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            do {
                let result = try await searchService.search(text: text)
                let objectsSearchData = result.compactMap { ObjectSearchData(details: $0) }
                
                guard objectsSearchData.isNotEmpty else {
                    searchData = []
                    return
                }
                
                searchData = [SearchDataSection(searchData: objectsSearchData, sectionName: "")]
                
            } catch {
                searchData = []
            }
        }.cancellable()
    }
}
