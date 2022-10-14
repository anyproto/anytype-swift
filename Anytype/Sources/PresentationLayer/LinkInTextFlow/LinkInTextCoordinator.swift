import Foundation
import UIKit
import BlocksModels
import AnytypeCore

protocol LinkInTextCoordinatorProtocol: AnyObject {
    func startFlow(blockId: BlockId, currentText: NSAttributedString, range: NSRange)
}

final class LinkInTextCoordinator: LinkInTextCoordinatorProtocol {
    
    private let rootViewController: UIViewController
    private let actionHandler: BlockActionHandlerProtocol
    private let pageService: PageServiceProtocol
    private let urlOpener: URLOpenerProtocol
    private let editorPageCoordinator: EditorPageCoordinatorProtocol
    
    init(
        rootViewController: UIViewController,
        actionHandler: BlockActionHandlerProtocol,
        pageService: PageServiceProtocol,
        urlOpener: URLOpenerProtocol,
        editorPageCoordinator: EditorPageCoordinatorProtocol
    ) {
        self.rootViewController = rootViewController
        self.actionHandler = actionHandler
        self.pageService = pageService
        self.urlOpener = urlOpener
        self.editorPageCoordinator = editorPageCoordinator
    }
    
    // MARK: - LinkInTextCoordinatorProtocol
        
    func startFlow(blockId: BlockId, currentText: NSAttributedString, range: NSRange) {
        
        let urlLink = currentText.linkState(range: range)
        let objectIdLink = currentText.linkToObjectState(range: range)
        let eitherLink: Either<URL, BlockId>? = urlLink.map { .left($0) } ?? objectIdLink.map { .right($0) } ?? nil
        
        let onLinkSelection: (LinkToObjectSearchViewModel.SearchKind) -> () = { [weak self] searchKind in
            switch searchKind {
            case let .object(linkBlockId):
                self?.actionHandler.setLinkToObject(linkBlockId: linkBlockId, range: range, blockId: blockId)
            case let .createObject(name):
                if let linkBlockId = self?.pageService.createPage(name: name) {
                    AnytypeAnalytics.instance().logCreateObject(objectType: ObjectTypeProvider.shared.defaultObjectType.url, route: .mention)
                    self?.actionHandler.setLinkToObject(linkBlockId: linkBlockId, range: range, blockId: blockId)
                }
            case let .web(url):
                self?.actionHandler.setLink(url: url, range: range, blockId: blockId)
            case let .openURL(url):
                self?.urlOpener.openUrl(url)
            case let .openObject(objectId):
                let data = EditorScreenData(pageId: objectId, type: .page)
                self?.editorPageCoordinator.startFlow(data: data, replaceCurrentPage: false)
            case .removeLink:
                switch eitherLink {
                case .right:
                    self?.actionHandler.setLinkToObject(linkBlockId: nil, range: range, blockId: blockId)
                case .left:
                    self?.actionHandler.setLink(url: nil, range: range, blockId: blockId)
                default:
                    break
                }
            case let .copyLink(url):
                UIPasteboard.general.string = url.absoluteString
            }
        }
        
        showLinkToObject(currentLink: eitherLink, onSelect: onLinkSelection)
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
