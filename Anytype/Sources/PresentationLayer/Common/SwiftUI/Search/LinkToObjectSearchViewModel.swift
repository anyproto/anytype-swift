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

    func search(text: String) {
        searchData.removeAll()

        let result = service.search(text: text)

        var objectData = result?.compactMap { searchData in
            LinkToObjectSearchData(searchData: searchData)
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

        searchData.append(SearchDataSection(searchData: objectData ?? [], sectionName: text.isNotEmpty ? "Objects".localized : ""))
    }

    init(onSelect: @escaping (SearchDataType) -> ()) {
        self.onSelect = onSelect
    }
}


struct LinkToObjectSearchData: SearchDataProtocol {
    let id = UUID()

    let searchKind: LinkToObjectSearchViewModel.SearchKind
    let searchTitle: String
    let description: String
    let iconImage: ObjectIconImage
    let callout: String
    let viewType: EditorViewType


    var shouldShowDescription: Bool {
        switch searchKind {
        case .object: return true
        case .web, .createObject: return false
        }
    }

    var shouldShowCallout: Bool {
        switch searchKind {
        case .object: return true
        case .web, .createObject: return false
        }
    }

    var descriptionTextColor: Color {
        return .textPrimary
    }

    var usecase: ObjectIconImageUsecase {
        switch searchKind {
        case .object: return .dashboardSearch
        case .web, .createObject: return .mention(.heading)
        }
    }
    
    init(searchData: SearchData) {
        self.searchKind = .object(searchData.id)
        self.searchTitle = searchData.title
        self.description = searchData.description
        self.viewType = searchData.editorViewType

        let layout = searchData.layout
        if layout == .todo {
            self.iconImage =  .todo(searchData.isDone)
        } else {
            self.iconImage = searchData.icon.flatMap { .icon($0) } ?? .placeholder(searchTitle.first)
        }

        callout = searchData.objectType.name
    }

    init(searchKind: LinkToObjectSearchViewModel.SearchKind, searchTitle: String, iconImage: ObjectIconImage) {
        self.searchKind = searchKind
        self.searchTitle = searchTitle
        self.iconImage = iconImage
        self.description = ""
        self.callout = ""
        self.viewType = .page
    }
}
