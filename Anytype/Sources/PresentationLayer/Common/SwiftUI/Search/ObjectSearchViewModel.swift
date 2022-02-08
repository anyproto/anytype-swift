import SwiftUI
import BlocksModels

enum SearchKind {
    case objects
    case objectTypes(currentObjectTypeUrl: String)
    
    var descriptionTextColor: Color {
        switch self {
        case .objects:
            return .textPrimary
        case .objectTypes:
            return .textSecondary
        }
    }
    
    var shouldShowCallout: Bool {
        switch self {
        case .objects:
            return true
        case .objectTypes:
            return false
        }
    }
}

/// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=6455%3A4097
final class ObjectSearchViewModel: SearchViewModelProtocol {
    @Published var searchData: [SearchDataSection<ObjectSearchData>] = []
    var onSelect: (ObjectSearchData) -> ()
    var onDismiss: () -> () = {}
    
    lazy var descriptionTextColor = searchKind.descriptionTextColor
    lazy var shouldShowCallout = searchKind.shouldShowCallout
    
    private let service = SearchService()
    private let searchKind: SearchKind
    
    init(searchKind: SearchKind, onSelect: @escaping (SearchDataType) -> ()) {
        self.searchKind = searchKind
        self.onSelect = onSelect
    }
    
    func search(text: String) {
        let result = searchDetails(text: text)
        let objectsSearchData = result?.compactMap { details in
            ObjectSearchData(searchKind: searchKind, details: details)
        }

        guard let objectsSearchData = objectsSearchData, objectsSearchData.isNotEmpty else {
            searchData = []
            return
        }

        searchData = [SearchDataSection(searchData: objectsSearchData, sectionName: "")]
    }
    
    private func searchDetails(text: String) -> [ObjectDetails]? {
        switch searchKind {
        case .objects:
            return service.search(text: text)
        case .objectTypes(let currentObjectTypeUrl):
            return service.searchObjectTypes(text: text, filteringTypeUrl: currentObjectTypeUrl)
        }
    }
}
