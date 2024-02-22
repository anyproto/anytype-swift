import Foundation
import UIKit
import Services
import AnytypeCore

@MainActor
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

@MainActor
final class LinkToObjectCoordinator: LinkToObjectCoordinatorProtocol {
    
    private let navigationContext: NavigationContextProtocol
    private let defaultObjectService: DefaultObjectCreationServiceProtocol
    private let urlOpener: URLOpenerProtocol
    private let searchService: SearchServiceProtocol
    private weak var output: LinkToObjectCoordinatorOutput?
    
    nonisolated init(
        navigationContext: NavigationContextProtocol,
        defaultObjectService: DefaultObjectCreationServiceProtocol,
        urlOpener: URLOpenerProtocol,
        searchService: SearchServiceProtocol,
        output: LinkToObjectCoordinatorOutput?
    ) {
        self.navigationContext = navigationContext
        self.defaultObjectService = defaultObjectService
        self.urlOpener = urlOpener
        self.searchService = searchService
        self.output = output
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
                    if let linkBlockDetails = try? await self?.defaultObjectService.createDefaultObject(name: name, shouldDeleteEmptyObject: false, spaceId: spaceId) {
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
                self?.output?.showPage(data: details.editorScreenData())
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

        navigationContext.presentSwiftUIView(view: linkToView)
    }
    
}
