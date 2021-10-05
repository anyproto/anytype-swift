import UIKit

final class EditorBottomNavigationView: UIView {
    private let onBackTap: () -> ()
    private let onForwardTap: () -> ()
    private let onHomeTap: () -> ()
    private let onSearchTap: () -> ()
    
    private lazy var backButton = createBackButton()
    private lazy var forwardButton = createForwardButton()
    private lazy var homeButton = createHomeButton()
    private lazy var searchButton = createSearchButton()
    
    init(
        onBackTap: @escaping () -> (),
        onForwardTap: @escaping () -> (),
        onHomeTap: @escaping () -> (),
        onSearchTap: @escaping () -> ()
    ) {
        self.onBackTap = onBackTap
        self.onForwardTap = onForwardTap
        self.onHomeTap = onHomeTap
        self.onSearchTap = onSearchTap
        
        super.init(frame: .zero)
        
        setup()
    }
    
    func setForwardButtonEnabled(_ enabled: Bool) {
        forwardButton.isEnabled = enabled
    }
    
    private func setup() {
        layoutUsing.anchors {
            $0.height.equal(to: 48)
        }
        
        layoutUsing.stack(
            layout: { stackView in
                stackView.layoutUsing.anchors {
                    $0.pinToSuperview(
                        excluding: [.top, .bottom],
                        insets: UIEdgeInsets(top: 0, left: 60, bottom: 0, right: -60)
                    )
                    $0.centerY.equal(to: self.centerYAnchor)
                }
            }
        ) {
            $0.hStack(
                distributedTo: .equalSpacing,
                [
                    homeButton,
                    backButton,
                    forwardButton,
                    searchButton
                ]
            )
        }
    }
    
    // MARK: - Views
    private func createBackButton() -> UIView {
        EditorBrowserButton(image: .editorNavigation.backArrow) { [weak self] in
            UISelectionFeedbackGenerator().selectionChanged()
            self?.onBackTap()
        }
    }
    
    private func createForwardButton() -> EditorBrowserButton {
        EditorBrowserButton(image: .editorNavigation.forwardArrow, isEnabled: false) { [weak self] in
            UISelectionFeedbackGenerator().selectionChanged()
            self?.onForwardTap()
        }
    }
    
    private func createHomeButton() -> UIView {
        EditorBrowserButton(image: .editorNavigation.home) { [weak self] in
            UISelectionFeedbackGenerator().selectionChanged()
            self?.onHomeTap()
        }
    }
    
    private func createSearchButton() -> UIView {
        EditorBrowserButton(image: .editorNavigation.search) { [weak self] in
            UISelectionFeedbackGenerator().selectionChanged()
            self?.onSearchTap()
        }
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
