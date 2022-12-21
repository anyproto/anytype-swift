import UIKit
import BlocksModels
import AnytypeCore

final class EditorBottomNavigationView: UIView {
    private let onBackTap: () -> ()
    private let onBackPageTap: (BrowserPage) -> ()
    private let onForwardTap: () -> ()
    private let onForwardPageTap: (BrowserPage) -> ()
    private let onHomeTap: () -> ()
    private let onCreateObjectTap: () -> ()
    
    private lazy var backButton = createBackButton()
    private lazy var forwardButton = createForwardButton()
    private lazy var homeButton = createHomeButton()
    private lazy var сreateObjectButton = createCreateObjectButton()
    
    init(
        onBackTap: @escaping () -> (),
        onBackPageTap: @escaping (BrowserPage) -> (),
        onForwardTap: @escaping () -> (),
        onForwardPageTap: @escaping (BrowserPage) -> (),
        onHomeTap: @escaping () -> (),
        onCreateObjectTap: @escaping () -> ()
    ) {
        self.onBackTap = onBackTap
        self.onBackPageTap = onBackPageTap
        self.onForwardTap = onForwardTap
        self.onForwardPageTap = onForwardPageTap
        self.onHomeTap = onHomeTap
        self.onCreateObjectTap = onCreateObjectTap
        
        super.init(frame: .zero)
        
        setup()
    }
    
    func update(openedPages: [BrowserPage], closedPages: [BrowserPage]) {
        forwardButton.isEnabled = closedPages.isNotEmpty
        backButton.updateMenu(buildBackButtonMenu(pages: openedPages))
        forwardButton.updateMenu(buildForwardButtonMenu(pages: closedPages))
    }
    
    private func setup() {
        backgroundColor = .BackgroundNew.primary
        
        layoutUsing.stack(
            layout: { stackView in
                stackView.layoutUsing.anchors {
                    $0.pinToSuperview(
                        excluding: [.bottom],
                        insets: UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
                    )
                    $0.height.equal(to: Constants.height)
                    $0.bottom.equal(to: self.safeAreaLayoutGuide.bottomAnchor)
                }
            }
        ) {
            $0.hStack(
                alignedTo: .center,
                distributedTo: .equalSpacing,
                [
                    homeButton,
                    backButton,
                    forwardButton,
                    сreateObjectButton
                ]
            )
        }
    }
    
    private func buildBackButtonMenu(pages: [BrowserPage]) -> UIMenu {
        var openedItems = pages
            .dropLast() // current opened page
            .reversed()
            .map { buildUIAction(page: $0, action: onBackPageTap) }
        
        let homeAction = UIAction(title: Loc.home) { [weak self] _ in
            self?.onHomeTap()
        }
        openedItems.append(homeAction)
        
        return UIMenu(title: "", children: openedItems)
    }
    
    private func buildForwardButtonMenu(pages: [BrowserPage]) -> UIMenu {
        let closedItems = pages.reversed().map { buildUIAction(page: $0, action: onForwardPageTap) }
        return UIMenu(title: "", children: closedItems)
    }
    
    private func buildUIAction(page: BrowserPage, action: @escaping (BrowserPage) -> ()) -> UIAction {
        if #available(iOS 15.0, *) {
            return UIAction(title: page.title ?? Loc.untitled, subtitle: page.subtitle ?? "") { _ in
                UISelectionFeedbackGenerator().selectionChanged()
                action(page)
            }
        } else {
            return UIAction(title: page.title ?? Loc.untitled) { _ in
                UISelectionFeedbackGenerator().selectionChanged()
                action(page)
            }
        }
    }
    
    // MARK: - Views
    private func createBackButton() -> EditorBrowserButton {
        EditorBrowserButton(imageAsset: .TextEditor.backArrow) { [weak self] in
            UISelectionFeedbackGenerator().selectionChanged()
            self?.onBackTap()
        }
    }
    
    private func createForwardButton() -> EditorBrowserButton {
        return EditorBrowserButton(imageAsset: .TextEditor.forwardArrow, isEnabled: false) { [weak self] in
            UISelectionFeedbackGenerator().selectionChanged()
            self?.onForwardTap()
        }
    }
    
    private func createHomeButton() -> UIView {
        EditorBrowserButton(imageAsset: .TextEditor.home) { [weak self] in
            UISelectionFeedbackGenerator().selectionChanged()
            self?.onHomeTap()
        }
    }
    
    private func createCreateObjectButton() -> UIView {
        EditorBrowserButton(imageAsset: .draft) { [weak self] in
            UISelectionFeedbackGenerator().selectionChanged()
            self?.onCreateObjectTap()
        }
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditorBottomNavigationView {
    
    enum Constants {
        static let height: CGFloat = 48
    }
    
}
