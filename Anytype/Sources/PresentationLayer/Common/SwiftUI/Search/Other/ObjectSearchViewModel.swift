import SwiftUI
import Services
import Combine

/// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=6455%3A4097
final class ObjectSearchViewModel: SearchViewModelProtocol {
    
    @Published var searchData: [SearchDataSection<ObjectSearchData>] = []
    
    var onSelectClosure: (ObjectSearchData) -> ()

    let placeholder: String = Loc.search
    
    private let spaceId: String
    private let searchService: SearchInteractorProtocol
    
    init(spaceId: String, searchService: SearchInteractorProtocol, onSelect: @escaping (SearchDataType) -> ()) {
        self.spaceId = spaceId
        self.searchService = searchService
        self.onSelectClosure = onSelect
    }
    
    func onSelect(searchData: ObjectSearchData) {
        onSelectClosure(searchData)
    }
    
    func search(text: String) async {
        do {
            let result = try await searchService.search(text: text, spaceId: spaceId)
            let objectsSearchData = result.compactMap { ObjectSearchData(details: $0) }
            
            guard objectsSearchData.isNotEmpty else {
                searchData = []
                return
            }
            
            searchData = [SearchDataSection(searchData: objectsSearchData, sectionName: "")]
            
        } catch {
            searchData = []
        }
    }
}
