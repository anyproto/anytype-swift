import Foundation
import UIKit


// MARK: Options
extension TopBottomMenuViewController {
    struct Options {
        var shouldAnimateToolbarAppearance: Bool = true
        var animationDuration: TimeInterval = 0.3
    }
}

// Top and bottom selecion item controlls
class TopBottomMenuViewController: UIViewController {
    /// Options
    private var options = Options()
    /// Views
    private var contentView: UIView = .init()
    private var topView: UIStackView = .init()
    private var containerView: UIView = .init()
    private var bottomView: UIStackView = .init()
    
    private var childViewController: UIViewController?

    // MARK: Configurations
    func configured(options: Options) -> Self {
        self.options = options
        return self
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.setupUIElements()
        self.addLayout()
        self.updateChildViewController()
    }

    // TODO: Extract to ChildNavigationController.
    /// ChildNavigationController will store ContentViewController.
    /// ContainerViewController will store and present NavigationController which will manipulates ChildNavigationController.
    private func configureNavigation(_ navigationItem: UINavigationItem) {        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .pureRed
        appearance.titleTextAttributes = [.foregroundColor: UIColor.lightText] // With a red background, make the title more readable.
        appearance.shadowColor = .clear
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance // For iPhone small navigation bar in landscape.
        
        // Make all buttons with green text.
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        navigationItem.standardAppearance?.buttonAppearance = buttonAppearance
        navigationItem.compactAppearance?.buttonAppearance = buttonAppearance // For iPhone small navigation bar in landscape.
        
        navigationItem.standardAppearance?.backButtonAppearance = buttonAppearance
        
        // Make the done style button with yellow text.
        let doneButtonAppearance = UIBarButtonItemAppearance()
        doneButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        navigationItem.standardAppearance?.doneButtonAppearance = doneButtonAppearance
        navigationItem.compactAppearance?.doneButtonAppearance = doneButtonAppearance // For iPhone small navigation bar in landscape.
    }

    func setupNavigation() {
        self.navigationItem.backBarButtonItem = .init(title: "", style: .plain, target: nil, action: nil)
        self.configureNavigation(self.navigationItem)
    }

    // MARK: Setup and Layout
    func setupUIElements() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.contentView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        self.topView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            return view
        }()
        self.containerView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        self.bottomView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            return view
        }()
        self.contentView.addSubview(self.topView)
        self.contentView.addSubview(self.containerView)
        self.contentView.addSubview(self.bottomView)
        self.view.addSubview(self.contentView)
    }
    
    func addLayout() {
        if let superview = self.contentView.superview {
            let view = self.contentView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
        if let superview = self.topView.superview {
            let view = self.topView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
            ]
            NSLayoutConstraint.activate(constraints)
        }
        if let superview = self.containerView.superview {
            let view = self.containerView
            let topView = self.topView
            let bottomView = self.bottomView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: topView.bottomAnchor),
                view.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
        if let superview = self.bottomView.superview {
            let view = self.bottomView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    func updateChildViewController() {        
        if let viewController = self.childViewController {
            self.addChild(viewController)
        }
        
        if let view = self.childViewController?.view {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.containerView.addSubview(view)
            if let superview = view.superview {
                let constraints = [
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ]
                NSLayoutConstraint.activate(constraints)
            }
        }
        self.didMove(toParent: self.childViewController)
    }
}

// MARK: Toolbar Views
// MARK: Toolbar Kind
extension TopBottomMenuViewController {
    enum Kind {
        case top
        case bottom
    }
}

// MARK: Check state
extension TopBottomMenuViewController {
    enum MenusState {
        case none
        case hasTop
        case hasBottom
        case hasBoth
    }
    func menusState() -> MenusState {
        switch (topView.arrangedSubviews.isEmpty, bottomView.arrangedSubviews.isEmpty) {
        case (true, true): return .none
        case (true, false): return .hasTop
        case (false, true): return .hasBottom
        case (false, false): return .hasBoth
        }
    }
}

extension TopBottomMenuViewController {
    // MARK: Toolbar Manipulations
    func toolbarView(by kind: Kind) -> UIStackView {
        switch kind {
        case .top: return self.topView
        case .bottom: return self.bottomView
        }
    }
    
    private func _add(subview: UIView?, onToolbar kind: Kind) {
        if let view = subview {
            let toolbarView = self.toolbarView(by: kind)
            toolbarView.addArrangedSubview(view)
            toolbarView.layoutIfNeeded()
            view.layoutIfNeeded()
            view.isHidden = true
        }
    }
    
    func add(subview: UIView?, onToolbar kind: Kind) {
        if self.options.shouldAnimateToolbarAppearance {
            self._add(subview: subview, onToolbar: kind)
            UIView.animate(withDuration: self.options.animationDuration) {
                self.toolbarView(by: kind).arrangedSubviews.first?.isHidden = false
                self.toolbarView(by: kind).layoutIfNeeded()
            }
        }
        else {
            self._add(subview: subview, onToolbar: kind)
        }
    }
    
    private func _removeSubview(fromToolbar kind: Kind) {
        let toolbarView = self.toolbarView(by: kind)
        
        if let view = toolbarView.arrangedSubviews.first {
            view.isHidden = true
        }
    }
    
    func removeSubview(fromToolbar kind: Kind) {
        if self.options.shouldAnimateToolbarAppearance {
            self.toolbarView(by: kind).setNeedsLayout()
            UIView.animate(withDuration: self.options.animationDuration, animations: {
                self._removeSubview(fromToolbar: kind)
                self.toolbarView(by: kind).layoutIfNeeded()
            }) { (value) in
                self.toolbarView(by: kind).subviews.forEach { (value) in
                    value.removeFromSuperview()
                }
            }
        }
        else {
            self._removeSubview(fromToolbar: kind)
        }
    }

    // MARK: Embed into Container
    private func _add(content: UIView?) {
        if let view = content {
            let superview = self.containerView
            superview.addSubview(view)
            
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ]
            
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    func add(content: UIView?) {
        if self.options.shouldAnimateToolbarAppearance {
            UIView.animate(withDuration: self.options.animationDuration) {
                self._add(content: content)
            }
        }
        else {
            self._add(content: content)
        }
    }
    
    private func _removeContent() {
        self.containerView.subviews.forEach { (value) in
            value.removeFromSuperview()
        }
    }
    
    func removeContent() {
        if self.options.shouldAnimateToolbarAppearance {
            UIView.animate(withDuration: self.options.animationDuration) {
                self.removeContent()
            }
        }
        else {
            self.removeContent()
        }
    }

    // MARK: Add Child
    func add(child controller: UIViewController?) {
        self.childViewController = controller
    }
}
