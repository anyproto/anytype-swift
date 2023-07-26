import Foundation
import UIKit
import Services
import AnytypeCore

protocol LinkToObjectCoordinatorProtocol: AnyObject {
    func startFlow(
        spaceId: String,
        currentLink: Either<URL, BlockId>?,
        setLinkToObject: @escaping (_ blockId: String) -> Void,
        setLinkToUrl: @escaping (_ url: URL) -> Void,
        removeLink: @escaping () -> Void,
        willShowNextScreen: (() -> Void)?
    )
}

final class LinkToObjectCoordinator: LinkToObjectCoordinatorProtocol {
    
    private let navigationContext: NavigationContextProtocol
    private let pageService: PageServiceProtocol
    private let urlOpener: URLOpenerProtocol
    private let editorPageCoordinator: EditorPageCoordinatorProtocol
    private let searchService: SearchServiceProtocol
    
    init(
        navigationContext: NavigationContextProtocol,
        pageService: PageServiceProtocol,
        urlOpener: URLOpenerProtocol,
        editorPageCoordinator: EditorPageCoordinatorProtocol,
        searchService: SearchServiceProtocol
    ) {
        self.navigationContext = navigationContext
        self.pageService = pageService
        self.urlOpener = urlOpener
        self.editorPageCoordinator = editorPageCoordinator
        self.searchService = searchService
    }
    
    // MARK: - LinkToObjectCoordinatorProtocol
        
    func startFlow(
        spaceId: String,
        currentLink: Either<URL, BlockId>?,
        setLinkToObject: @escaping (_ blockId: String) -> Void,
        setLinkToUrl: @escaping (_ url: URL) -> Void,
        removeLink: @escaping () -> Void,
        willShowNextScreen: (() -> Void)?
    ) {
        
        let onLinkSelection: (LinkToObjectSearchViewModel.SearchKind) -> () = { [weak self] searchKind in
            switch searchKind {
            case let .object(linkBlockId):
                setLinkToObject(linkBlockId)
            case let .createObject(name):
                Task { @MainActor [weak self] in
                    if let linkBlockDetails = try? await self?.pageService.createPage(name: name, spaceId: spaceId) {
                        AnytypeAnalytics.instance().logCreateObject(objectType: linkBlockDetails.analyticsType, route: .mention)
                        setLinkToObject(linkBlockDetails.id)
                    }
                }
            case let .web(url):
                setLinkToUrl(url)
            case let .openURL(url):
                willShowNextScreen?()
                self?.urlOpener.openUrl(url)
            case let .openObject(details):
                willShowNextScreen?()
                self?.editorPageCoordinator.startFlow(data: details.editorScreenData(), replaceCurrentPage: false)
            case .removeLink:
                removeLink()
            case let .copyLink(url):
                UIPasteboard.general.string = url.absoluteString
            }
        }
        
        showLinkToObject(spaceId: spaceId, currentLink: currentLink, onSelect: onLinkSelection)
    }
    
    
    // MARK: - Private
    
    func showLinkToObject(
        spaceId: String,
        currentLink: Either<URL, BlockId>?,
        onSelect: @escaping (LinkToObjectSearchViewModel.SearchKind) -> ()
    ) {
        let viewModel = LinkToObjectSearchViewModel(spaceId: spaceId, currentLink: currentLink, searchService: searchService) { data in
            onSelect(data.searchKind)
        }
        let linkToView = SearchView(title: Loc.linkTo, viewModel: viewModel)

        navigationContext.presentSwiftUIView(view: linkToView, model: viewModel)
    }
    
}
