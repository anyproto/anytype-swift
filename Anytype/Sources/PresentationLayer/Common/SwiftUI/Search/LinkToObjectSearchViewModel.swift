import SwiftUI
import BlocksModels


final class LinkToObjectSearchViewModel: SearchViewModelProtocol {
    enum SearchKind {
        case web(String)
        case createObject(String)
        case object(BlockId)
    }

    typealias SearchDataType = LinkToObjectSearchData

    private let service = SearchService()

    let descriptionTextColor: Color = .textPrimary
    let shouldShowCallout: Bool = true

    @Published var searchData: [SearchDataSection<SearchDataType>] = []
    
    var onSelect: (SearchDataType) -> ()
    var onDismiss: () -> () = { }

    var placeholder: String {
        return Loc.pasteLinkOrSearchObjects
    }

    func search(text: String) {
        searchData.removeAll()

        let result = service.search(text: text)

        var objectData = result?.compactMap { details in
            LinkToObjectSearchData(details: details)
        }

        if text.isNotEmpty {
            let webSearchData = LinkToObjectSearchData(
                searchKind: .web(text),
                searchTitle: text,
                iconImage: .imageAsset(.slashMenuStyleLink))

            let webSection = SearchDataSection(searchData: [webSearchData], sectionName: Loc.webPages)
            searchData.append(webSection)

            let title = Loc.createObject + "  " + "\"" + text + "\""
            let createObjectData = LinkToObjectSearchData(searchKind: .createObject(text),
                                                          searchTitle: title,
                                                          iconImage: .imageAsset(.createNewObject))
            objectData?.insert(createObjectData, at: 0)
        }

        searchData.append(SearchDataSection(searchData: objectData ?? [], sectionName: Loc.objects))
    }

    init(onSelect: @escaping (SearchDataType) -> ()) {
        self.onSelect = onSelect
    }
}
