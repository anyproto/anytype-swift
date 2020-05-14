//
//  DocumentViewController+HeaderView.swift
//  AnyType
//
//  Created by Batvinkin Denis on 07.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit
import Combine

extension DocumentViewController {

    /// Header view with navigation controls
    class HeaderView: UIView {

        enum Style {
            case presentation
            func backgroundColor() -> UIColor {
                switch self {
                case .presentation: return .white
                }
            }
        }
        
        // MARK: Variables
        private var layout: Layout = .init()
        private var viewModel: ViewModel
        private var subscriptions: Set<AnyCancellable> = []
        
        // MARK: Actions
        @objc private func processBackButtonPressed() {
            self.process(action: .didTapBackButton)
        }
        
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
        
        private lazy var backButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "back"), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(processBackButtonPressed), for: .touchUpInside)
            return button
        }()

        private lazy var horizontalStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.alignment = .fill
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.directionalLayoutMargins = self.layout.directionalEdgeInstets

            return stackView
        }()
        
        private lazy var verticalStackView: UIStackView = {
            let stackView = UIStackView()

            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.alignment = .fill
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.directionalLayoutMargins = self.layout.directionalEdgeInstets
            
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
            horizontalStackView.addArrangedSubview(backButton)
            horizontalStackView.addArrangedSubview(UIView())
            verticalStackView.addArrangedSubview(horizontalStackView)
            
            contentView.addSubview(verticalStackView)
            addSubview(contentView)
        }

        private func setupLayout() {
            NSLayoutConstraint.activate([
                backButton.widthAnchor.constraint(equalToConstant: 24),
                backButton.heightAnchor.constraint(equalToConstant: 24),
            ])
            
            let view = verticalStackView
                        
            if let superview = view.superview {
                let constraints = [
                    view.leftAnchor.constraint(equalTo: superview.leftAnchor),
                    view.rightAnchor.constraint(equalTo: superview.rightAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ]
                NSLayoutConstraint.activate(constraints)
            }
            
            let contentView = self.contentView
            
            if let superview = contentView.superview {
                let constraints = [
                    view.leftAnchor.constraint(equalTo: superview.leftAnchor),
                    view.rightAnchor.constraint(equalTo: superview.rightAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ]
                NSLayoutConstraint.activate(constraints)
            }
        }
    }
}

// MARK: Layout
private extension DocumentViewController.HeaderView {
    struct Layout {
        var directionalEdgeInstets: NSDirectionalEdgeInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
    }
}

// MARK: ViewModel
extension DocumentViewController.HeaderView {
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
extension DocumentViewController.HeaderView.ViewModel {
    func configured(pageDetailsViewModels: [BlockViewBuilderProtocol]) -> Self {
        self.pageDetailsViewModels = pageDetailsViewModels
        self.userEvent = .pageDetailsViewModelsDidSet
        return self
    }
}
