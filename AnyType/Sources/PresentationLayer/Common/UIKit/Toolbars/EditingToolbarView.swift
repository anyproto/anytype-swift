//
//  EditingToolbarView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 14.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


/// Editing Toolbar
///
/// [Design.](https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Android-main-draft?node-id=3618%3A40)
class EditingToolbarView: UIView {
    typealias ActionHandler = (Action) -> Void

    /// Actions that emit toolbar on selection buttons
    enum Action {
        /// Slash button pressed
        case slashMenu
        /// Multiselect button pressed
        case multiActionMenu
        /// Done button pressed
        case keyboardDismiss
    }

    // MARK: - Views

    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually

        return stackView
    }()

    private var actionHandler: ActionHandler?

    // MARK: - Lifecycle

    init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: .zero, height: 48)))

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @available(*, unavailable)
    override init(frame: CGRect) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup views

    private func setupViews() {
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        addSubview(stackView)

        setupLayout()
    }

    private func setupLayout() {
        stackView.edgesToSuperview()
    
        addBarButtonItem(image: UIImage(named: "EditingToolbar/add_new")) { [weak self] _ in
            self?.actionHandler?(.slashMenu)
        }

        addBarButtonItem(image: UIImage(named: "EditingToolbar/style")) {_ in
            assertionFailure("Not implemented yet")
        }

        addBarButtonItem(image: UIImage(named: "EditingToolbar/move")) { [weak self] _ in
            self?.actionHandler?(.multiActionMenu)
        }

        addBarButtonItem(image: UIImage(named: "EditingToolbar/mention")) {_ in
            assertionFailure("Not implemented yet")
        }

        addBarButtonItem(title: "Done".localized) { [weak self]_ in
            self?.actionHandler?(.keyboardDismiss)
        }
    }

    // MARK: - Private methods

    /// Add bar item with title and image.
    /// - Parameters:
    ///   - title: Title. If nil a title is not displayed.
    ///   - image: Image. If nil a image is not displayed.
    ///   - action: Action performed on touch
    private func addBarButtonItem(title: String? = nil, image: UIImage? = nil, action: @escaping UIActionHandler) {
        let primaryAction = UIAction(handler: action)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.activeOrange, for: .normal)
        button.addAction(primaryAction, for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }

    // MARK: - Public methods

    /// Set action handler to this toolbar
    /// - Parameter actionHandler: Handler that proccess toolbar actions
    func setActionHandler(_ actionHandler: @escaping ActionHandler) {
        self.actionHandler = actionHandler
    }
}
