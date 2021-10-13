import UIKit
import BlocksModels
import AnytypeCore

final class EditorBrowserController: UIViewController, UINavigationControllerDelegate {
        
    var childNavigation: UINavigationController!
    var router: EditorRouterProtocol!
    
    private lazy var navigationView: EditorBottomNavigationView = createNavigationView()
    
    private let stateManager = BrowserNavigationManager()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    func setup() {
        childNavigation.delegate = self
        
        view.addSubview(navigationView) {
            $0.pinToSuperview(excluding: [.top, .bottom])
            $0.bottom.equal(to: view.safeAreaLayoutGuide.bottomAnchor)
        }
        
        embedChild(childNavigation, into: view)
        childNavigation.view.layoutUsing.anchors {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.equal(to: navigationView.topAnchor)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
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
                
                self.router.showPage(with: page.blockId)
            },
            onForwardPageTap: { [weak self] page in
                guard let self = self else { return }
                do {
                    try self.stateManager.moveForward(page: page)
                } catch let error {
                    anytypeAssertionFailure(error.localizedDescription)
                    self.navigationController?.popViewController(animated: true)
                }
                
                self.router.showPage(with: page.blockId)
            },
            onHomeTap: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onSearchTap: { [weak self] in
                self?.router.showSearch { blockId in
                    self?.router.showPage(with: blockId)
                }
            }
        )
    }
    
    // MARK: - Private
    private func pop() {
        if childNavigation.children.count > 1 {
            childNavigation.popViewController(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }    
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UINavigationControllerDelegate
        
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let viewController = viewController as? EditorPageController else {
            anytypeAssertionFailure("Not supported browser controller: \(viewController)")
            return
        }
        
        let documentId = viewController.viewModel.document.objectId
        UserDefaultsConfig.storeOpenedPageId(documentId)
        
        let details = viewController.viewModel.document.getDetails(id: documentId)
        let title = details?.name
        let subtitle = details?.description
        do {
            try stateManager.didShow(
                page: BrowserPage(
                    blockId: viewController.viewModel.document.objectId,
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
