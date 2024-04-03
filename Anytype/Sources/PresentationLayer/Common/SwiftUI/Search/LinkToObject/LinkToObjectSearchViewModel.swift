import SwiftUI
import Services
import AnytypeCore

final class LinkToObjectSearchViewModel: SearchViewModelProtocol {
    enum SearchKind {
        case web(URL)
        case createObject(String)
        case object(String)
        case openURL(URL)
        case openObject(ObjectDetails)
        case removeLink
        case copyLink(URL)
    }

    typealias SearchDataType = LinkToObjectSearchData

    @Injected(\.searchService)
    private var searchService: SearchServiceProtocol
    @Injected(\.pasteboardHelper)
    private var pasteboardHelper: PasteboardHelperProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: DefaultObjectCreationServiceProtocol
    
    private let data: LinkToObjectSearchModuleData
    private let showEditorScreen: (_ data: EditorScreenData) -> Void
    
    let descriptionTextColor: Color = .Text.primary
    let shouldShowCallout: Bool = true
    
    @Published var searchData: [SearchDataSection<SearchDataType>] = []
    
    var searchTask: Task<(), Never>?
    var placeholder: String { Loc.Editor.LinkToObject.searchPlaceholder }

    init(data: LinkToObjectSearchModuleData, showEditorScreen: @escaping (_ data: EditorScreenData) -> Void) {
        self.data = data
        self.showEditorScreen = showEditorScreen
    }

    func search(text: String) {
        searchTask?.cancel()
        searchData.removeAll()
        
        searchTask = Task { @MainActor [weak self, data] in
            guard let result = try? await self?.searchService.search(text: text, spaceId: data.spaceId) else { return }
            self?.handleSearch(result: result, text: text)
        }
    }
    
    func onSelect(searchData: LinkToObjectSearchData) {
        switch searchData.searchKind {
        case let .object(linkBlockId):
            data.setLinkToObject(linkBlockId)
        case let .createObject(name):
            Task { @MainActor [weak self, data] in
                if let linkBlockDetails = try? await self?.defaultObjectService.createDefaultObject(name: name, shouldDeleteEmptyObject: false, spaceId: data.spaceId) {
                    AnytypeAnalytics.instance().logCreateObject(objectType: linkBlockDetails.analyticsType, route: .mention)
                    data.setLinkToObject(linkBlockDetails.id)
                }
            }
        case let .web(url):
            data.setLinkToUrl(url)
        case let .openURL(url):
            data.willShowNextScreen?()
//            urlOpener.openUrl(url)
        case let .openObject(details):
            data.willShowNextScreen?()
            showEditorScreen(details.editorScreenData())
        case .removeLink:
            data.removeLink()
        case let .copyLink(url):
            UIPasteboard.general.string = url.absoluteString
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
                    iconImage: .asset(.webPage))
                
                let webSection = SearchDataSection(searchData: [webSearchData], sectionName: Loc.webPages)
                searchData.append(webSection)
            }
            
            let title = Loc.createObject + "  " + "\"" + text + "\""
            let createObjectData = LinkToObjectSearchData(searchKind: .createObject(text),
                                                          searchTitle: title,
                                                          iconImage: .asset(.createNewObject))
            objectData.insert(createObjectData, at: 0)
        }
        
        if text.isEmpty {
            if pasteboardHelper.hasValidURL,
               let pasteboardString = pasteboardHelper.obtainString(),
               let url = AnytypeURL(string: pasteboardString) {
                let webSearchData = LinkToObjectSearchData(
                    searchKind: .web(url.url),
                    searchTitle: Loc.Editor.LinkToObject.pasteFromClipboard,
                    iconImage: .asset(.webPage))
                
                let webSection = SearchDataSection(searchData: [webSearchData], sectionName: Loc.webPages)
                searchData.append(webSection)
            }
        }
        
        searchData.append(SearchDataSection(searchData: objectData, sectionName: Loc.objects))
    }

    private func buildExistingLinkSections(currentLink: Either<URL, String>) async throws -> [SearchDataSection<SearchDataType>] {
        let linkedToData: LinkToObjectSearchData?
        let copyLink: LinkToObjectSearchData?

        switch currentLink {
        case let .left(url):
            linkedToData = LinkToObjectSearchData(
                searchKind: .openURL(url),
                searchTitle: url.absoluteString,
                iconImage: .asset(.webPage)
            )

            copyLink = LinkToObjectSearchData(
                searchKind: .copyLink(url),
                searchTitle: Loc.Editor.LinkToObject.copyLink,
                iconImage: .asset(.TextEditor.BlocksOption.copy)
            )
        case let .right(blockId):
            let result = try await searchService.search(text: "", spaceId: data.spaceId)
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
            iconImage: .asset(.TextEditor.BlocksOption.delete)
        )

        let actionsSection = SearchDataSection(
            searchData: [removeLink, copyLink].compactMap { $0 },
            sectionName: Loc.actions
        )

        return [linkedToSection, actionsSection]
    }
}
