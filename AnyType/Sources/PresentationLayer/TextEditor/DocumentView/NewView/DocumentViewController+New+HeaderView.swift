//
//  DocumentViewController+New+HeaderView.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 05.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

fileprivate typealias Namespace = DocumentModule.DocumentViewController

extension Namespace {

    /// Header view with navigation controls
    class HeaderView: UIView {
        
        // MARK: Variables
        private var layout: Layout = .init()
        private var viewModel: ViewModel
        private var subscriptions: Set<AnyCancellable> = []
        
        private func process(action: UserAction) {
            self.viewModel.process(action: action)
        }
        
        // MARK: Events
        private func process(event: UserEvent) {
            switch event {
            case .pageDetailsViewModelsDidSet:
                // add page details to stackView?
                self.viewModel.pageDetailsViewModels.map({$0.buildUIView()}).forEach { view in
                    self.verticalStackView.addArrangedSubview(view)
                }
            }
        }
        
        // MARK: Views
        private lazy var contentView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = Style.presentation.backgroundColor()
            return view
        }()
        
        private lazy var horizontalStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.alignment = .fill
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.translatesAutoresizingMaskIntoConstraints = false
//            stackView.directionalLayoutMargins = self.layout.directionalEdgeInsets

            return stackView
        }()
        
        private lazy var verticalStackView: UIStackView = {
            let stackView = UIStackView()

            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.alignment = .fill
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.directionalLayoutMargins = self.layout.directionalEdgeInsets
            
            return stackView
        }()

        // MARK: Initialization
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
                        
            super.init(frame: .zero)
            self.setup()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: Setup
        private func setupSubscribers() {
            self.viewModel.$userEvent.safelyUnwrapOptionals().sink { [weak self] (value) in
                self?.process(event: value)
            }.store(in: &self.subscriptions)
        }
        
        private func setup() {
            self.setupSubscribers()
            self.setupView()
            self.setupLayout()
        }
        
        private func setupView() {
            self.translatesAutoresizingMaskIntoConstraints = false
//            self.horizontalStackView.addArrangedSubview(UIView())
//            self.verticalStackView.addArrangedSubview(self.horizontalStackView)
            
            self.contentView.addSubview(self.verticalStackView)
            self.addSubview(self.contentView)
        }

        private func setupLayout() {
            let view = self.verticalStackView
                        
            if let superview = view.superview {
                let constraints = [
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ]
                NSLayoutConstraint.activate(constraints)
            }
                        
            let contentView = self.contentView
            
            if let superview = contentView.superview {
                let constraints = [
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ]
                NSLayoutConstraint.activate(constraints)
            }
        }
        override var intrinsicContentSize: CGSize {
            return .zero
        }
    }
}

// MARK: Style
extension Namespace.HeaderView {
    enum Style {
        case presentation
        func backgroundColor() -> UIColor {
            switch self {
            case .presentation: return .white
            }
        }
    }
}

// MARK: Layout
private extension Namespace.HeaderView {
    struct Layout {
        var directionalEdgeInsets: NSDirectionalEdgeInsets = .init(top: 12, leading: 20, bottom: 12, trailing: 20)
    }
}

// MARK: ViewModel
extension Namespace.HeaderView {
    enum UserAction {
        case didTapBackButton
    }
    
    enum UserEvent {
        case pageDetailsViewModelsDidSet
    }
    
    class ViewModel {
        // MARK: Publishers
        @Published var userAction: UserAction?
        @Published fileprivate var userEvent: UserEvent?
        fileprivate var pageDetailsViewModels: [BlockViewBuilderProtocol] = []
        
        // MARK: Process actions
        func process(action: UserAction) {
            self.userAction = action
        }
    }
}

// MARK: ViewModel / Configuration
extension Namespace.HeaderView.ViewModel {
    func configured(pageDetailsViewModels: [BlockViewBuilderProtocol]) -> Self {
        self.pageDetailsViewModels = pageDetailsViewModels
        self.userEvent = .pageDetailsViewModelsDidSet
        return self
    }
}
