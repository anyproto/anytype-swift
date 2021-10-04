import UIKit

final class EditorNavigationViewController: UIViewController {
    
    private let childNavigation: UINavigationController
    init(child: UINavigationController) {
        self.childNavigation = child
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    private func setup() {
        embedChild(childNavigation, into: view)
        
        view.addSubview(bottomNavigationView) {
            $0.pinToSuperview(excluding: [.top])
        }
        
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
        }
    )
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
