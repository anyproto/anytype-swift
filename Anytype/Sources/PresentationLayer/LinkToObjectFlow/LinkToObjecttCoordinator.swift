import Foundation
import UIKit
import BlocksModels
import AnytypeCore

protocol LinkToObjectCoordinatorProtocol: AnyObject {
    func startFlow(
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
                if let linkBlockId = self?.pageService.createPage(name: name) {
                    AnytypeAnalytics.instance().logCreateObject(objectType: ObjectTypeProvider.shared.defaultObjectType.id, route: .mention)
                    setLinkToObject(linkBlockId)
                }
            case let .web(url):
                setLinkToUrl(url)
            case let .openURL(url):
                willShowNextScreen?()
                self?.urlOpener.openUrl(url)
            case let .openObject(objectId):
                willShowNextScreen?()
                let data = EditorScreenData(pageId: objectId, type: .page)
                self?.editorPageCoordinator.startFlow(data: data, replaceCurrentPage: false)
            case .removeLink:
                removeLink()
            case let .copyLink(url):
                UIPasteboard.general.string = url.absoluteString
            }
        }
        
        showLinkToObject(currentLink: currentLink, onSelect: onLinkSelection)
    }
    
    
    // MARK: - Private
    
    func showLinkToObject(
        currentLink: Either<URL, BlockId>?,
        onSelect: @escaping (LinkToObjectSearchViewModel.SearchKind) -> ()
    ) {
        let viewModel = LinkToObjectSearchViewModel(currentLink: currentLink, searchService: searchService) { data in
            onSelect(data.searchKind)
        }
        let linkToView = SearchView(title: Loc.linkTo, context: .menuSearch, viewModel: viewModel)

        navigationContext.presentSwiftUIView(view: linkToView, model: viewModel)
    }
    
}
