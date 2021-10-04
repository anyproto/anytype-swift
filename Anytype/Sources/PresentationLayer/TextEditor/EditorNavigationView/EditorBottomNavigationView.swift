import UIKit

final class EditorBottomNavigationView: UIView {
    private let onBackTap: () -> ()
    private let onHomeTap: () -> ()
    
    private lazy var backButton = createBackButton()
    private lazy var homeButton = createHomeButton()
    private lazy var searchButton = createSearchButton()
    
    init(
        onBackTap: @escaping () -> (),
        onHomeTap: @escaping () -> ()
    ) {
        self.onBackTap = onBackTap
        self.onHomeTap = onHomeTap
        
        super.init(frame: .zero)
        
        setup()
    }
    
    private func setup() {
        layoutUsing.anchors {
            $0.height.equal(to: 48)
        }
        
        layoutUsing.stack(
            layout: { stackView in
                stackView.layoutUsing.anchors {
                    $0.pinToSuperview(
                        insets: UIEdgeInsets(top: 0, left: 60, bottom: 0, right: -60)
                    )
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
    
    // MARK: - Views
    private func createBackButton() -> UIView {
        let view = UIButton(
            type: .system,
            primaryAction: UIAction { [weak self] _ in
                self?.onBackTap()
            }
        )
        
        view.setImage(UIImage.backArrow, for: .normal)
        view.tintColor = .textSecondary
        
        view.layoutUsing.anchors {
            $0.height.equal(to: 24)
            $0.width.equal(to: 24)
        }
        return view
    }
    
    private func createHomeButton() -> UIView {
        let view = UIButton(
            type: .system,
            primaryAction: UIAction { [weak self] _ in
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
    }
    
    private func createSearchButton() -> UIView {
        let view = UIButton(
            type: .system,
            primaryAction: UIAction { [weak self] _ in
                // TODO
            }
        )
        
        view.setImage(UIImage.editorNavigation.search, for: .normal)
        view.tintColor = .textSecondary
        
        view.layoutUsing.anchors {
            $0.height.equal(to: 24)
            $0.width.equal(to: 24)
        }
        
        return view
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
