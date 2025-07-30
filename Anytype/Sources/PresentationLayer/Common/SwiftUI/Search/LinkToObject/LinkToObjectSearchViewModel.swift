import SwiftUI
import Services
import AnytypeCore

@MainActor
final class LinkToObjectSearchViewModel: ObservableObject {
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
    private var searchService: any SearchServiceProtocol
    @Injected(\.pasteboardHelper)
    private var pasteboardHelper: any PasteboardHelperProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: any DefaultObjectCreationServiceProtocol
    
    private let data: LinkToObjectSearchModuleData
    private let showEditorScreen: (_ data: ScreenData) -> Void
    
    let descriptionTextColor: Color = .Text.primary
    let shouldShowCallout: Bool = true
    
    @Published var searchData: [SearchDataSection<SearchDataType>] = []
    @Published var openUrl: URL?
    
    init(data: LinkToObjectSearchModuleData, showEditorScreen: @escaping (_ data: ScreenData) -> Void) {
        self.data = data
        self.showEditorScreen = showEditorScreen
    }

    func search(text: String) async {
        do {
            if data.currentLinkUrl.isNotNil || data.currentLinkString.isNotNil, text.isEmpty {
                let sections = try await buildExistingLinkSections()
                searchData = sections
            } else {
                let result = try await searchService.search(text: text, spaceId: data.spaceId)
                searchData = handleSearch(result: result, text: text)
            }
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            searchData.removeAll()
        }
    }
    
    func onSelect(searchData: LinkToObjectSearchData) {
        switch searchData.searchKind {
        case let .object(linkBlockId):
            data.setLinkToObject(linkBlockId)
        case let .createObject(name):
            Task { @MainActor [weak self, data] in
                if let linkBlockDetails = try? await self?.defaultObjectService.createDefaultObject(name: name, shouldDeleteEmptyObject: false, spaceId: data.spaceId) {
                    AnytypeAnalytics.instance().logCreateObject(objectType: linkBlockDetails.analyticsType, spaceId: linkBlockDetails.spaceId, route: data.route)
                    data.setLinkToObject(linkBlockDetails.id)
                }
            }
        case let .web(url):
            data.setLinkToUrl(url)
        case let .openURL(url):
            data.willShowNextScreen?()
            openUrl = url
        case let .openObject(details):
            data.willShowNextScreen?()
            showEditorScreen(details.screenData())
        case .removeLink:
            data.removeLink()
        case let .copyLink(url):
            UIPasteboard.general.string = url.absoluteString
        }
    }
    
    private func handleSearch(result: [ObjectDetails], text: String) -> [SearchDataSection<SearchDataType>] {
        var newSearchData: [SearchDataSection<SearchDataType>] = []
        
        var objectData = result.compactMap { details in
            LinkToObjectSearchData(details: details)
        }
        
        if text.isNotEmpty {
            if text.isValidURL(), let url = AnytypeURL(string: text) {
                let webSearchData = LinkToObjectSearchData(
                    searchKind: .web(url.url),
                    searchTitle: text,
                    iconImage: .asset(.webPage))
                
                let webSection = SearchDataSection(searchData: [webSearchData], sectionName: Loc.linkTo)
                newSearchData.append(webSection)
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
                
                let webSection = SearchDataSection(searchData: [webSearchData], sectionName: Loc.linkTo)
                newSearchData.append(webSection)
            }
        }
        
        if objectData.isNotEmpty {
            newSearchData.append(SearchDataSection(searchData: objectData, sectionName: Loc.objects))
        }
        
        return newSearchData
    }

    private func buildExistingLinkSections() async throws -> [SearchDataSection<SearchDataType>] {
        var linkedToData: LinkToObjectSearchData? = nil
        var copyLink: LinkToObjectSearchData? = nil

        if let url = data.currentLinkUrl {
            linkedToData = LinkToObjectSearchData(
                searchKind: .openURL(url),
                searchTitle: url.absoluteString,
                iconImage: .asset(.webPage)
            )
            
            copyLink = LinkToObjectSearchData(
                searchKind: .copyLink(url),
                searchTitle: Loc.copyLink,
                iconImage: .asset(.TextEditor.BlocksOption.copy)
            )
        } else if let blockId = data.currentLinkString {
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
