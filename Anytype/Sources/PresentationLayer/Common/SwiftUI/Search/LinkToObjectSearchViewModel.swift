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
        return "Paste link or search objects".localized
    }

    func search(text: String) {
        searchData.removeAll()

        let result = service.search(text: text)

        var objectData = result?.compactMap { details in
            LinkToObjectSearchData(details: details)
        }

        if text.isNotEmpty {
            let icon = UIImage.createImage(ImageName.slashMenu.style.link)
            let webSearchData = LinkToObjectSearchData(
                searchKind: .web(text),
                searchTitle: text,
                iconImage: .image(icon))

            let webSection = SearchDataSection(searchData: [webSearchData], sectionName: "Web pages".localized)
            searchData.append(webSection)

            let createObjectIcon = UIImage.createImage("createNewObject")
            let title = "Create object".localized + "  " + "\"" + text + "\""
            let createObjectData = LinkToObjectSearchData(searchKind: .createObject(text),
                                                          searchTitle: title,
                                                          iconImage: .image(createObjectIcon))
            objectData?.insert(createObjectData, at: 0)
        }

        searchData.append(SearchDataSection(searchData: objectData ?? [], sectionName: "Objects".localized))
    }

    init(onSelect: @escaping (SearchDataType) -> ()) {
        self.onSelect = onSelect
    }
}
