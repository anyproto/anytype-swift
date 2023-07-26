import UIKit
import Services
import AnytypeCore

protocol EditorBrowser: AnyObject {
    func pop()
    func popIfPresent(_ viewController: UIViewController)
    func goToHome(animated: Bool)
    func showPage(data: EditorScreenData)
    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool)
}

protocol EditorBrowserViewInputProtocol: AnyObject {
    func didShow(collectionView: UICollectionView)
}

protocol EditorPageOpenRouterProtocol: AnyObject {
    // TODO: set main action with delete homeWidgets toggle
    func showPage(data: EditorScreenData)
}

final class EditorBrowserController: UIViewController, UINavigationControllerDelegate, EditorBrowser, EditorBrowserViewInputProtocol {
        
    var childNavigation: UINavigationController!
    weak var router: EditorPageOpenRouterProtocol!

    private lazy var navigationView: EditorBottomNavigationView = createNavigationView()
    private var navigationViewBottomConstaint: NSLayoutConstraint?
    
    private let dashboardService: DashboardServiceProtocol
    private let accountManager: AccountManagerProtocol
    private let stateManager = BrowserNavigationManager()
    private let browserView = EditorBrowserView()
    private var isNavigationViewHidden = false
    
    init(dashboardService: DashboardServiceProtocol, accountManager: AccountManagerProtocol) {
        self.dashboardService = dashboardService
        self.accountManager = accountManager
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        view = browserView
    }
    
    func setup() {
        view.backgroundColor = .Background.primary
        childNavigation.delegate = self
        
        view.addSubview(navigationView) {
            $0.pinToSuperviewPreservingReadability(excluding: [.top, .bottom])
            navigationViewBottomConstaint = $0.bottom.equal(to: view.bottomAnchor)
        }
        
        embedChild(childNavigation, into: view)
        childNavigation.view.layoutUsing.anchors {
            $0.pinToSuperviewPreservingReadability(excluding: [.bottom])
            $0.bottom.equal(to: view.bottomAnchor)
        }

        view.bringSubviewToFront(navigationView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navigationController, !navigationController.viewControllers.contains(where: { $0 == self}) {
            UserDefaultsConfig.lastOpenedPage = nil
        }
    }
    
    // MARK: - Views
    private func createNavigationView() -> EditorBottomNavigationView {
        EditorBottomNavigationView(
            onBackTap: { [weak self] in
                self?.pop()
            },
            onBackPageTap: { [weak self] page in
                guard let self = self else { return }
                guard let controller = page.controller else { return }
                do {
                    try self.stateManager.moveBack(page: page)
                } catch let error {
                    anytypeAssertionFailure(error.localizedDescription)
                    self.navigationController?.popViewController(animated: true)
                }

                self.childNavigation.popToViewController(controller, animated: true)
            },
            onForwardTap: { [weak self] in
                guard let self = self else { return }
                guard let page = self.stateManager.closedPages.last else { return }
                guard self.stateManager.moveForwardOnce() else { return }
                
                self.router.showPage(data: page.pageData)
            },
            onForwardPageTap: { [weak self] page in
                guard let self = self else { return }
                do {
                    try self.stateManager.moveForward(page: page)
                } catch let error {
                    anytypeAssertionFailure(error.localizedDescription)
                    self.navigationController?.popViewController(animated: true)
                }
                
                self.router.showPage(data: page.pageData)
            },
            onHomeTap: { [weak self] in
                AnytypeAnalytics.instance().logShowHome(view: .widget)
                self?.goToHome(animated: true)
            },
            onCreateObjectTap: { [weak self] in
                Task { @MainActor in
                    guard let self = self,
                          let details = try? await self.dashboardService.createNewPage(spaceId: self.accountManager.account.info.accountSpaceId) else {
                        return
                    }
                    AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .navigation, view: .navbar)
                    self.router.showPage(data: details.editorScreenData())
                }
            }
        )
    }
    
    func pop() {        
        if childNavigation.children.count > 1 {
            childNavigation.popViewController(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func popIfPresent(_ viewController: UIViewController) {
        guard childNavigation.topViewController == viewController else { return }
        pop()
    }
    
    func goToHome(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
    
    func showPage(data: EditorScreenData) {
        router.showPage(data: data)
    }
    
    func didShow(collectionView: UICollectionView) {
        browserView.childCollectionView = collectionView
    }

    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool) {
        navigationViewBottomConstaint?.constant = isHidden ? view.safeAreaInsets.bottom + EditorBottomNavigationView.Constants.height : 0
        isNavigationViewHidden = isHidden
        
        UIView.animate(
            withDuration: animated ? 0.3 : 0,
            delay: 0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.navigationView.layoutIfNeeded()
            }, completion: nil
        )
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UINavigationControllerDelegate
        
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let detailsProvider = viewController as? DocumentDetaisProvider else {
            anytypeAssertionFailure("Not supported browser controller", info: ["controller": "\(viewController)"])
            return
        }
        
        UserDefaultsConfig.lastOpenedPage = detailsProvider.screenData
        
        let title = detailsProvider.documentTitle
        let subtitle = detailsProvider.documentDescription
        do {
            try stateManager.didShow(
                page: BrowserPage(
                    pageData: detailsProvider.screenData,
                    title: title,
                    subtitle: subtitle,
                    controller: viewController
                ),
                childernCount: childNavigation.children.count
            )
        } catch let error {
            anytypeAssertionFailure(error.localizedDescription)
            self.navigationController?.popViewController(animated: true)
        }
        
        navigationView.update(
            openedPages: stateManager.openedPages,
            closedPages: stateManager.closedPages
        )
    }
}

extension EditorBrowserController {
    override var bottomToastOffset: CGFloat {
        isNavigationViewHidden ? super.bottomToastOffset : EditorBottomNavigationView.Constants.height
    }
}
