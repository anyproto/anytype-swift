import UIKit
import BlocksModels
import AnytypeCore

protocol EditorBrowser: AnyObject {
    func pop()
    func goToHome(animated: Bool)
    func showPage(data: EditorScreenData)
    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool)
}

protocol EditorBrowserViewInputProtocol: AnyObject {
    func multiselectActive(_ active: Bool)
    func onScroll(bottom: Bool)
    func didShow(collectionView: UICollectionView)
}

final class EditorBrowserController: UIViewController, UINavigationControllerDelegate, EditorBrowser, EditorBrowserViewInputProtocol {
        
    var childNavigation: UINavigationController!
    var router: EditorRouterProtocol!

    private lazy var navigationView: EditorBottomNavigationView = createNavigationView()
    private var navigationViewBottomConstaint: NSLayoutConstraint?
    
    private let dashboardService = ServiceLocator.shared.dashboardService()
    private let stateManager = BrowserNavigationManager()
    private let browserView = EditorBrowserView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        view = browserView
    }
    
    func setup() {
        view.backgroundColor = .backgroundPrimary
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
        
        if let navigationController = navigationController as? NavigationControllerWithSwiftUIContent {
            navigationController.anytype_setNavigationBarHidden(true, animated: false)
        } else {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navigationController = navigationController as? NavigationControllerWithSwiftUIContent {
            navigationController.anytype_setNavigationBarHidden(false, animated: false)
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
                    anytypeAssertionFailure(error.localizedDescription, domain: .editorBrowser)
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
                    anytypeAssertionFailure(error.localizedDescription, domain: .editorBrowser)
                    self.navigationController?.popViewController(animated: true)
                }
                
                self.router.showPage(data: page.pageData)
            },
            onHomeTap: { [weak self] in
                self?.goToHome(animated: true)
            },
            onCreateObjectTap: { [weak self] in
                guard let self = self else { return }
                guard let id = self.dashboardService.createNewPage() else { return }
                
                AnytypeAnalytics.instance().logCreateObjectNavBar(
                    objectType: ObjectTypeProvider.shared.defaultObjectType.url
                )
                
                self.router.showPage(data: EditorScreenData(pageId: id, type: .page))
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
    
    func goToHome(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
    
    func showPage(data: EditorScreenData) {
        router.showPage(data: data)
    }
    
    private var isMultiselectActive = false
    func multiselectActive(_ active: Bool) {
        isMultiselectActive = active
        updateNavigationVisibility(animated: false)
    }
    
    private var scrollDirectionBottom = false
    func onScroll(bottom: Bool) {
        guard !isMultiselectActive, scrollDirectionBottom != bottom else { return }
        scrollDirectionBottom = bottom
        updateNavigationVisibility(animated: true)
    }
    
    func didShow(collectionView: UICollectionView) {
        browserView.childCollectionView = collectionView
    }
    
    private func updateNavigationVisibility(animated: Bool) {
        guard !isMultiselectActive else {
            setNavigationViewHidden(true, animated: animated)
            return
        }
        
        if scrollDirectionBottom {
            setNavigationViewHidden(true, animated: animated)
        } else {
            setNavigationViewHidden(false, animated: animated)
        }
    }

    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool) {
        navigationViewBottomConstaint?.constant = isHidden ? view.safeAreaInsets.bottom + EditorBottomNavigationView.Constants.height : 0
        
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
            anytypeAssertionFailure("Not supported browser controller: \(viewController)", domain: .editorBrowser)
            return
        }
        
        UserDefaultsConfig.storeOpenedScreenData(detailsProvider.screenData)
        
        let details = detailsProvider.details
        let title = details?.title
        let subtitle = details?.description
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
            anytypeAssertionFailure(error.localizedDescription, domain: .editorBrowser)
            self.navigationController?.popViewController(animated: true)
        }
        
        navigationView.update(
            openedPages: stateManager.openedPages,
            closedPages: stateManager.closedPages
        )
    }
}
