//
//  DocumentHeaderView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 11.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

/// Header view with navigation controls
public final class DocumentHeaderView: UICollectionReusableView {
    
    // MARK: - Views

    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.directionalLayoutMargins = Constants.directionalEdgeInsets

        return stackView
    }()
    
    // MARK: - Variables
    
    private(set) var viewModel: DocumentHeaderView.ViewModel?
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        .zero
    }
    
}

// MARK: - ViewModel

public extension DocumentHeaderView {
    
    final class ViewModel {
        
        // MARK: Publishers
        
        @Published var pageDetailsViewModels: [BlockViewBuilderProtocol] = []
    }
    
}

// MARK: - ConfigurableView

extension DocumentHeaderView: ConfigurableView {
    
    public func configure(model: ViewModel) {
        viewModel = model
        viewModel?.$pageDetailsViewModels
            .sink { [weak self] value in
                self?.handlePageDetailsViewModels(value)
            }
            .store(in: &self.subscriptions)
    }
    
}

// MARK: - Private extension

private extension DocumentHeaderView {
    
    // MARK: Layout
    
    func setupLayout() {
        addSubview(verticalStackView)
        verticalStackView.pinAllEdges(to: self)
    }
    
    // MARK: Event handler
    
    func handlePageDetailsViewModels(_ models: [BlockViewBuilderProtocol]) {
        models
            .map { $0.buildUIView() }
            .forEach { self.verticalStackView.addArrangedSubview($0) }
    }
}

// MARK: - Constants

private extension DocumentHeaderView {
    
    struct Constants {
        static let directionalEdgeInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 0,
            bottom: 12,
            trailing: 0
        )
    }
}
