import Foundation
import UIKit
import Combine
import SwiftUI
import os

enum MultiSelectionPaneDoneAction {
    case done
}

enum MultiSelectionPaneDoneUserResponse {}

class MultiSelectionPaneDoneView: UIView {
    /// Aliases
    fileprivate typealias Style = MultiSelectionPaneSelectionView.Style
    
    /// Variables
    private var style: Style = .default
    private var model = MultiSelectionPaneDoneViewModel()
    
    /// Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    init(viewModel: MultiSelectionPaneDoneViewModel) {
        self.model = viewModel
        super.init(frame: .zero)
        self.setup()
    }
    
    /// Actions
    private func update(response: MultiSelectionPaneDoneUserResponse) {
        /// Fill if you need a reaction on UserResponse
    }
    
    @objc func processOnClick() {
        self.process(.done)
    }
    private func process(_ action: MultiSelectionPaneDoneAction) {
        self.model.process(action: action)
    }
    
    /// Setup
    private func setupCustomization() {
        self.backgroundColor = self.style.backgroundColor()

        for button in [self.button] {
            button?.tintColor = self.style.normalColor()
        }

        self.button.addTarget(self, action: #selector(Self.processOnClick), for: .touchUpInside)
    }

    private func setupInteraction() {}

    // MARK: Setup
    private func setup() {
        self.setupUIElements()
        self.addLayout()
        self.setupCustomization()
        self.setupInteraction()
    }

    // MARK: UI Elements
    private var button: UIButton!
    private var contentView: UIView!

    // MARK: Setup UI Elements
    func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.button = {
            let view = UIButton(type: .system)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.titleLabel?.font = .preferredFont(forTextStyle: .title3)
            view.setTitle("Done", for: .normal)
            return view
        }()

        self.contentView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.contentView.addSubview(self.button)
        self.addSubview(self.contentView)
    }

    // MARK: Layout
    func addLayout() {
        if let view = self.button, let superview = view.superview {
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
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

