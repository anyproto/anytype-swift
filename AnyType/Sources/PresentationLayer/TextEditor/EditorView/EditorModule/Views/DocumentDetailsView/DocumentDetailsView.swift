//
//  DocumentDetailsView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 11.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class DocumentDetailsView: UICollectionReusableView {
    
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
    
    private(set) weak var viewModel: DocumentDetailsViewModel?
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

// MARK: - ConfigurableView

extension DocumentDetailsView: ConfigurableView {
    
    public func configure(model: DocumentDetailsViewModel) {
        viewModel = model
        viewModel?.$childViewModels
            .sink { [weak self] viewModels in
                self?.handleDetailsChildViewModels(viewModels)
            }
            .store(in: &self.subscriptions)
    }
    
}

// MARK: - Private extension

private extension DocumentDetailsView {
    
    // MARK: Layout
    
    func setupLayout() {
        addSubview(verticalStackView)
        verticalStackView.pinAllEdges(to: self)
    }
    
    // MARK: Event handler
    
    func handleDetailsChildViewModels(_ viewModels: [DocumentDetailsChildViewModel]) {
        viewModels
            .map { $0.makeView() }
            .forEach { self.verticalStackView.addArrangedSubview($0) }
    }
}

// MARK: - Constants

private extension DocumentDetailsView {
    
    struct Constants {
        static let directionalEdgeInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 20,
            bottom: 12,
            trailing: 20
        )
    }
}
