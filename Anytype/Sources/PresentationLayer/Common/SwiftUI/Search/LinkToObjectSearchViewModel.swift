import SwiftUI
import BlocksModels
import AnytypeCore

final class LinkToObjectSearchViewModel: SearchViewModelProtocol {
    enum SearchKind {
        case web(URL)
        case createObject(String)
        case object(BlockId)
        case openURL(URL)
        case openObject(BlockId)
        case removeLink
        case copyLink(URL)
    }

    typealias SearchDataType = LinkToObjectSearchData

    private let service = SearchService()
    private let pasteboardHelper: PasteboardHelper
    private let currentLink: Either<URL, BlockId>?

    let descriptionTextColor: Color = .textPrimary
    let shouldShowCallout: Bool = true

    @Published var searchData: [SearchDataSection<SearchDataType>] = []
    
    var onSelect: (SearchDataType) -> ()
    var onDismiss: () -> () = { }

    var placeholder: String { Loc.Editor.LinkToObject.searchPlaceholder }

    init(
        currentLink: Either<URL, BlockId>?,
        onSelect: @escaping (SearchDataType) -> (),
        pasteboardHelper: PasteboardHelper = PasteboardHelper()
    ) {
        self.currentLink = currentLink
        self.onSelect = onSelect
        self.pasteboardHelper = pasteboardHelper
    }

    func search(text: String) {
        searchData.removeAll()

        if let currentLink = currentLink, text.isEmpty {
            searchData.append(
                contentsOf: buildExistingLinkSections(currentLink: currentLink)
            )

            return
        }

        let result = service.search(text: text)

        var objectData = result?.compactMap { details in
            LinkToObjectSearchData(details: details)
        }

        if text.isNotEmpty {
            if text.isValidURL(), let url = AnytypeURL(string: text) {
                let webSearchData = LinkToObjectSearchData(
                    searchKind: .web(url.url),
                    searchTitle: text,
                    iconImage: .imageAsset(.webPage))

                let webSection = SearchDataSection(searchData: [webSearchData], sectionName: Loc.webPages)
                searchData.append(webSection)
            }

            let title = Loc.createObject + "  " + "\"" + text + "\""
            let createObjectData = LinkToObjectSearchData(searchKind: .createObject(text),
                                                          searchTitle: title,
                                                          iconImage: .imageAsset(.createNewObject))
            objectData?.insert(createObjectData, at: 0)
        }

        if text.isEmpty {
            if pasteboardHelper.hasValidURL,
               let pasteboardString = pasteboardHelper.obrainString(),
               let url = AnytypeURL(string: pasteboardString) {
                let webSearchData = LinkToObjectSearchData(
                    searchKind: .web(url.url),
                    searchTitle: Loc.Editor.LinkToObject.pasteFromClipboard,
                    iconImage: .imageAsset(.webPage))

                let webSection = SearchDataSection(searchData: [webSearchData], sectionName: Loc.webPages)
                searchData.append(webSection)
            }
        }

        searchData.append(SearchDataSection(searchData: objectData ?? [], sectionName: Loc.objects))
    }

    func buildExistingLinkSections(currentLink: Either<URL, BlockId>) -> [SearchDataSection<SearchDataType>] {
        let linkedToData: LinkToObjectSearchData?
        let copyLink: LinkToObjectSearchData?

        switch currentLink {
        case let .left(url):
            linkedToData = LinkToObjectSearchData(
                searchKind: .openURL(url),
                searchTitle: url.absoluteString,
                iconImage: .imageAsset(.webPage)
            )

            copyLink = LinkToObjectSearchData(
                searchKind: .copyLink(url),
                searchTitle: Loc.Editor.LinkToObject.copyLink,
                iconImage: .imageAsset(.TextEditor.BlocksOption.copy)
            )
        case let .right(blockId):
            let result = service.search(text: "")

            let object = result?.first(where: { $0.id == blockId })

            linkedToData = object.map {
                LinkToObjectSearchData(details: $0, searchKind: .openObject(blockId))
            }
            copyLink = nil
        }


        let linkedToSection = SearchDataSection(
            searchData: [linkedToData].compactMap { $0 },
            sectionName: Loc.Editor.LinkToObject.linkedTo
        )

        let removeLink = LinkToObjectSearchData(
            searchKind: .removeLink,
            searchTitle: Loc.Editor.LinkToObject.removeLink,
            iconImage: .imageAsset(.TextEditor.BlocksOption.delete)
        )

        let actionsSection = SearchDataSection(
            searchData: [removeLink, copyLink].compactMap { $0 },
            sectionName: Loc.actions
        )

        return [linkedToSection, actionsSection]
    }
}
