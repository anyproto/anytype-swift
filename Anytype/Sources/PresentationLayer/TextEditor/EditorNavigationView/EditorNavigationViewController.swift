import UIKit

final class EditorNavigationViewController: UIViewController {
    
    private let child: UIViewController
    init(child: UIViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
        
        setup(child: child)
    }
    
    private func setup(child: UIViewController) {
        embedChild(child, into: view)
        
        view.addSubview(bottomNavigationView) {
            $0.pinToSuperview(excluding: [.top])
        }
        
        child.view.layoutUsing.anchors {
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
