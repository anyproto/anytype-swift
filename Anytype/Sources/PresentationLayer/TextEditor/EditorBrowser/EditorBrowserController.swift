import UIKit
import BlocksModels
import AnytypeCore

final class EditorBrowserController: UIViewController, UINavigationControllerDelegate {
        
    var childNavigation: UINavigationController!
    var router: EditorRouterProtocol!
    
    private lazy var navigationView: EditorBottomNavigationView = createNavigationView()
    
    private let stateManager = BrowserStateManager()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    func setup() {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        childNavigation.delegate = self
    }
    
    // MARK: - Views
    private func createNavigationView() -> EditorBottomNavigationView {
        EditorBottomNavigationView(
            onBackTap: { [weak self] in
                guard let self = self else { return }
                
                if self.childNavigation.children.count > 1 {
                    self.childNavigation.popViewController(animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            },
            onForwardTap: { [weak self] in
                guard let self = self else { return }
                guard let pageId = self.stateManager.lastClosedPage else { return }
                if self.stateManager.nextIsForward { return }
                
                self.stateManager.nextIsForward = true
                self.router.showPage(with: pageId)
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
        
        UserDefaultsConfig.lastOpenedPageId = viewController.viewModel.documentId
        
        stateManager.didShow(
            blockId: viewController.viewModel.documentId,
            childernCount: childNavigation.children.count
        )
        
        navigationView.setForwardButtonEnabled(stateManager.lastClosedPage != nil)
    }
}
