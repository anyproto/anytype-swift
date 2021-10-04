import UIKit

final class EditorBottomNavigationView: UIView {
    private var height: NSLayoutConstraint!
    private let onHomeTap: () -> ()
    
    init(onHomeTap: @escaping () -> ()) {
        self.onHomeTap = onHomeTap
        
        super.init(frame: .zero)
        
        setup()
    }
    
    private func setup() {
        layoutUsing.anchors {
            height = $0.height.equal(to: 48)
        }
        
        layoutUsing.stack(
            layout: { stackView in
                stackView.layoutUsing.anchors {
                    $0.pinToSuperview(
                        excluding: [.bottom],
                        insets: UIEdgeInsets(top: 0, left: 60, bottom: 0, right: -60)
                    )
                    $0.height.equal(to: 48)
                }
            }
        ) {
                $0.hStack(
                    distributedTo: .equalSpacing,
                    [
                        backButton,
                        homeButton,
                        searchButton
                    ]
                )
            }

    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        guard let newWindow = newWindow else { return }
        
        let safeAreaBottom = newWindow.safeAreaInsets.bottom
        height.constant = 48 + safeAreaBottom
    }
    
    // MARK: - Views
    private let backButton: UIView = {
        let view = UIButton()
        
        view.setImage(UIImage.backArrow, for: .normal)
        view.tintColor = .textSecondary
        
        view.layoutUsing.anchors {
            $0.height.equal(to: 24)
            $0.width.equal(to: 24)
        }
        return view
    }()
    
    private lazy var homeButton: UIView = {
        let view = UIButton(
            type: .system,
            primaryAction: UIAction { [weak self] action in
                self?.onHomeTap()
            }
        )
        view.setImage(UIImage.editorNavigation.home, for: .normal)
        view.tintColor = .textSecondary
        
        view.layoutUsing.anchors {
            $0.height.equal(to: 24)
            $0.width.equal(to: 24)
        }
        return view
    }()
    
    private let searchButton: UIView = {
        let view = UIButton()
        view.setImage(UIImage.editorNavigation.search, for: .normal)
        view.tintColor = .textSecondary
        
        view.layoutUsing.anchors {
            $0.height.equal(to: 24)
            $0.width.equal(to: 24)
        }
        return view
    }()
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
