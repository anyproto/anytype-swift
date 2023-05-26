import SwiftUI
import Services

/// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=6455%3A4097
final class ObjectSearchViewModel: SearchViewModelProtocol {
    
    @Published var searchData: [SearchDataSection<ObjectSearchData>] = []
    
    var onSelect: (ObjectSearchData) -> ()
    var onDismiss: () -> () = {}

    let placeholder: String = Loc.search
    
    private let searchService: SearchServiceProtocol
    
    init(searchService: SearchServiceProtocol, onSelect: @escaping (SearchDataType) -> ()) {
        self.searchService = searchService
        self.onSelect = onSelect
    }
    
    func search(text: String) {
        let result = searchDetails(text: text)
        let objectsSearchData = result?.compactMap { ObjectSearchData(details: $0) }

        guard let objectsSearchData = objectsSearchData, objectsSearchData.isNotEmpty else {
            searchData = []
            return
        }

        searchData = [SearchDataSection(searchData: objectsSearchData, sectionName: "")]
    }
    
    private func searchDetails(text: String) -> [ObjectDetails]? {
        searchService.search(text: text)
    }
}
