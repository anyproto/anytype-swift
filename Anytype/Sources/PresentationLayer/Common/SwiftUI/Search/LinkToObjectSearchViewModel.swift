import SwiftUI
import Services
import AnytypeCore

final class LinkToObjectSearchViewModel: SearchViewModelProtocol {
    enum SearchKind {
        case web(URL)
        case createObject(String)
        case object(BlockId)
        case openURL(URL)
        case openObject(ObjectDetails)
        case removeLink
        case copyLink(URL)
    }

    typealias SearchDataType = LinkToObjectSearchData

    private let searchService: SearchServiceProtocol
    private let pasteboardHelper: PasteboardHelper
    private let currentLink: Either<URL, BlockId>?

    let descriptionTextColor: Color = .Text.primary
    let shouldShowCallout: Bool = true
    
    @Published var searchData: [SearchDataSection<SearchDataType>] = []
    
    var onSelect: (SearchDataType) -> ()
    var onDismiss: () -> () = { }
    var searchTask: Task<(), Never>?

    var placeholder: String { Loc.Editor.LinkToObject.searchPlaceholder }

    init(
        currentLink: Either<URL, BlockId>?,
        searchService: SearchServiceProtocol,
        pasteboardHelper: PasteboardHelper = PasteboardHelper(),
        onSelect: @escaping (SearchDataType) -> ()
    ) {
        self.currentLink = currentLink
        self.searchService = searchService
        self.pasteboardHelper = pasteboardHelper
        self.onSelect = onSelect
    }

    func search(text: String) {
        searchTask?.cancel()
        searchData.removeAll()

        searchTask = Task { @MainActor [weak self] in
            guard let result = try? await self?.searchService.search(text: text) else { return }
            self?.handleSearch(result: result, text: text)
        }
    }
    
    func handleSearch(result: [ObjectDetails], text: String) {
        var objectData = result.compactMap { details in
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
            objectData.insert(createObjectData, at: 0)
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
        
        searchData.append(SearchDataSection(searchData: objectData, sectionName: Loc.objects))
    }

    func buildExistingLinkSections(currentLink: Either<URL, BlockId>) async throws -> [SearchDataSection<SearchDataType>] {
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
            let result = try await searchService.search(text: "")
            let object = result.first(where: { $0.id == blockId })

            linkedToData = object.map {
                LinkToObjectSearchData(details: $0, searchKind: .openObject($0))
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
