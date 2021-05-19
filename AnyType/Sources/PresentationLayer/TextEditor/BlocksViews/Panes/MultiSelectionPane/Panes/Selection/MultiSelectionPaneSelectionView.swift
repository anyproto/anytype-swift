import Foundation
import UIKit
import Combine
import SwiftUI
import os

extension MultiSelectionPane.Panes {
    enum Selection {}
}


// MARK: Action
enum MultiSelectionPaneSelectionAction {
    case selectAll(MultiSelectionPaneSelectAllAction)
    case done(MultiSelectionPaneDoneAction)
}

enum MultiSelectionPaneSelectionUserResponse {
    case selection(MultiSelectionPaneSelectAllUserResponse)
}


class MultiSelectionPaneSelectionView: UIView {
    // MARK: Aliases
    typealias Style = BlockTextView.Style

    // MARK: Variables
    var style: Style = .default
    let model: MultiSelectionPaneSelectionViewModel
    var userResponseSubscription: AnyCancellable?

    // MARK: Initialization
    override init(frame: CGRect) {
        model = .init()
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        model = .init()
        super.init(coder: coder)
        self.setup()
    }
    
    init(viewModel: MultiSelectionPaneSelectionViewModel) {
        self.model = viewModel
        super.init(frame: .zero)
        self.setup()
    }

    // MARK: Actions
    private func update(response: MultiSelectionPaneSelectionUserResponse) {
        // send to a view model (?)
    }

    // MARK: Public API Configurations
    // something that we should put in public api.

    private func setupCustomization() {
        self.backgroundColor = self.style.backgroundColor()
    }

    private func setupInteraction() {
        self.userResponseSubscription = self.model.userResponse.sink { [weak self] (value) in
            self?.update(response: value)
        }
    }

    // MARK: Setup
    private func setup() {
        self.setupUIElements()
        self.addLayout()
        self.setupCustomization()
        self.setupInteraction()
    }

    // MARK: UI Elements
    private var selectionButton: MultiSelectionPaneSelectAllView!
    private var doneButton: MultiSelectionPaneDoneView!

    private var contentView: UIView!

    // MARK: Setup UI Elements
    func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.selectionButton = {
            // Ask view model for correct view model.
            .init(viewModel: self.model.selectAllViewModel())
        }()

        self.doneButton = {
            .init(viewModel: self.model.doneViewModel())
        }()

        self.contentView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.contentView.addSubview(self.selectionButton)
        self.contentView.addSubview(self.doneButton)
        self.addSubview(self.contentView)
    }

    // MARK: Layout
    func addLayout() {
        let offset: CGFloat = 10
        if let view = self.selectionButton, let superview = view.superview {
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: offset).isActive = true
            view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
        
        if let view = self.doneButton, let superview = view.superview, let leftView = self.selectionButton {
            view.leadingAnchor.constraint(greaterThanOrEqualTo: leftView.trailingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -offset).isActive = true
            view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
        
        if let view = self.contentView, let superview = view.superview {
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }

    override var intrinsicContentSize: CGSize {
        return .zero
    }
}
