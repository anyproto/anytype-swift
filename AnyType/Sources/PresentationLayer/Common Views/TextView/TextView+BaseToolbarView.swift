//
//  TextView+BaseToolbarView.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import UIKit

// MARK: Style
extension TextView {
    enum Style {
        static let `default`: Self = .presentation
        case debug, presentation
        func normalColor() -> UIColor {
            switch self {
            case .debug: return .white
            case .presentation: return .gray
            }
        }
        func highlightedColor() -> UIColor {
            switch self {
            case .debug: return .orange
            case .presentation: return .black
            }
        }
        func backgroundColor() -> UIColor {
            switch self {
            case .debug: return .darkGray
            case .presentation: return .white
            }
        }
        func color(for state: Bool) -> UIColor {
            state ? highlightedColor() : normalColor()
        }
    }
}

// MARK: Layout
extension TextView {
    struct Layout {
        static var `default` = Self.init()
        enum StackViewSpacing {
            case `default`, gap, custom
            func size() -> CGFloat {
                switch self {
                case .default: return 16.0
                case .gap: return Self.custom.size() * 2
                case .custom: return Self.default.size()
                }
            }
        }
        var marginOffset: CGFloat = 16.0
        func leadingOffset() -> CGFloat { marginOffset }
        func trailingOffset() -> CGFloat { marginOffset * (-1) }
        func topOffset() -> CGFloat { marginOffset * 0.5 }
        func bottomOffset() -> CGFloat { marginOffset * (-1) * 0.5 }
    }
}

// MARK: BaseToolbarView
extension TextView {
    /// This is base toolbar view with two left and right stack view.
    ///
    class BaseToolbarView: UIView {
        // MARK: Views
        var contentView: UIView!
        var leftStackView: UIStackView!
        var rightStackView: UIStackView!

        // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }

        // MARK: Setup
        private func setup() {
            self.setupUIElements()
            self.addLayout()
        }

        // MARK: UI Elements
        private func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false

            self.leftStackView = { () -> UIStackView in
                let view = UIStackView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.axis = .horizontal
                view.distribution = .fillEqually
                return view
            }()

            self.rightStackView = { () -> UIStackView in
                let view = UIStackView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.axis = .horizontal
                view.distribution = .fillEqually
                return view
            }()

            self.leftStackView.spacing = Layout.StackViewSpacing.default.size()
            self.rightStackView.spacing = Layout.StackViewSpacing.default.size()
            //            self.rightStackView.setCustomSpacing(Layout.StackViewSpacing.custom.size(), after: self.changeColorButton)

            self.contentView = { () -> UIView in
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.contentView.addSubview(leftStackView)
            self.contentView.addSubview(rightStackView)
            self.addSubview(contentView)
        }

        // MARK: Layout
        private func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: TextView.Layout.default.leadingOffset()).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: TextView.Layout.default.trailingOffset()).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: TextView.Layout.default.topOffset()).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: TextView.Layout.default.bottomOffset()).isActive = true
            }
            if let view = self.leftStackView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
            if let view = self.rightStackView, let superview = view.superview {
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
        }
    }
}

// MARK: BaseSingleToolbarView
extension TextView {
    /// This is base tooblar view with Single stack view.
    ///
    class BaseSingleToolbarView: UIView {
        // MARK: Views
        var contentView: UIView!
        var stackView: UIStackView!

        // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }

        // MARK: Setup
        private func setup() {
            self.setupUIElements()
            self.addLayout()
        }

        // MARK: UI Elements
        private func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false

            self.stackView = { () -> UIStackView in
                let view = UIStackView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.axis = .horizontal
                view.distribution = .fillEqually
                return view
            }()

            self.stackView.spacing = Layout.StackViewSpacing.default.size()

            self.contentView = { () -> UIView in
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.contentView.addSubview(stackView)
            self.addSubview(contentView)
        }

        // MARK: Layout
        private func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: TextView.Layout.default.leadingOffset()).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: TextView.Layout.default.trailingOffset()).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: TextView.Layout.default.topOffset()).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: TextView.Layout.default.bottomOffset()).isActive = true
            }
            if let view = self.stackView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            }
        }
    }
}
