import UIKit

final class EditorBrowserController: UIViewController {
    
    private let childNavigation: UINavigationController
    private let router: EditorRouterProtocol
    
    init(
        child: UINavigationController,
        router: EditorRouterProtocol
    ) {
        self.childNavigation = child
        self.router = router
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    private func setup() {
        view.addSubview(bottomNavigationView) {
            $0.pinToSuperview(excluding: [.top, .bottom])
            $0.bottom.equal(to: view.safeAreaLayoutGuide.bottomAnchor)
        }
        
        embedChild(childNavigation, into: view)
        childNavigation.view.layoutUsing.anchors {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.equal(to: bottomNavigationView.topAnchor)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Views
    private lazy var bottomNavigationView = EditorBottomNavigationView(
        onBackTap: { [weak self] in
            guard let self = self else { return }
            
            if self.childNavigation.children.count > 1 {
                self.childNavigation.popViewController(animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
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
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
