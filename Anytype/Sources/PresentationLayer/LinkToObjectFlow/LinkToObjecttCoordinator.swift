import Foundation
import UIKit
import BlocksModels
import AnytypeCore

protocol LinkToObjectCoordinatorProtocol: AnyObject {
    func startFlow(
        currentLink: Either<URL, BlockId>?,
        setLinkToObject: @escaping (_ blockId: String) -> Void,
        setLinkToUrl: @escaping (_ url: URL) -> Void,
        removeLink: @escaping () -> Void
    )
}

final class LinkToObjectCoordinator: LinkToObjectCoordinatorProtocol {
    
    private let rootViewController: UIViewController
    private let pageService: PageServiceProtocol
    private let urlOpener: URLOpenerProtocol
    private let editorPageCoordinator: EditorPageCoordinatorProtocol
    
    init(
        rootViewController: UIViewController,
        pageService: PageServiceProtocol,
        urlOpener: URLOpenerProtocol,
        editorPageCoordinator: EditorPageCoordinatorProtocol
    ) {
        self.rootViewController = rootViewController
        self.pageService = pageService
        self.urlOpener = urlOpener
        self.editorPageCoordinator = editorPageCoordinator
    }
    
    // MARK: - LinkToObjectCoordinatorProtocol
        
    func startFlow(
        currentLink: Either<URL, BlockId>?,
        setLinkToObject: @escaping (_ blockId: String) -> Void,
        setLinkToUrl: @escaping (_ url: URL) -> Void,
        removeLink: @escaping () -> Void
    ) {
        
        let onLinkSelection: (LinkToObjectSearchViewModel.SearchKind) -> () = { [weak self] searchKind in
            switch searchKind {
            case let .object(linkBlockId):
                setLinkToObject(linkBlockId)
            case let .createObject(name):
                if let linkBlockId = self?.pageService.createPage(name: name) {
                    AnytypeAnalytics.instance().logCreateObject(objectType: ObjectTypeProvider.shared.defaultObjectType.url, route: .mention)
                    setLinkToObject(linkBlockId)
                }
            case let .web(url):
                setLinkToUrl(url)
            case let .openURL(url):
                self?.urlOpener.openUrl(url)
            case let .openObject(objectId):
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
        let viewModel = LinkToObjectSearchViewModel(currentLink: currentLink) { data in
            onSelect(data.searchKind)
        }
        let linkToView = SearchView(title: Loc.linkTo, context: .menuSearch, viewModel: viewModel)

        rootViewController.topPresentedController.presentSwiftUIView(view: linkToView, model: viewModel)
    }
    
}
