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

    private let iconView: DocumentIconView = DocumentIconView()
    
    // MARK: - Variables
    
    private weak var viewModel: DocumentDetailsViewModel?
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override functions
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        subscriptions.forEach { $0.cancel() }
        viewModel = nil
    }
    
}

// MARK: - ConfigurableView

extension DocumentDetailsView: ConfigurableView {
    
    func configure(model: DocumentDetailsViewModel) {
        subscriptions.forEach { $0.cancel() }
        
        viewModel = model
        viewModel?.$iconEmoji
            .sink { [weak self] newIconEmoji in
                self?.handleIconEmojiUpdate(newIconEmoji)
            }
            .store(in: &subscriptions)
    }
    
}

// MARK: - Private extension

private extension DocumentDetailsView {
    
    // MARK: Layout
    
    func setupLayout() {
        layoutUsing.stack {
            $0.vStack(
                $0.vGap(fixed: Constants.directionalEdgeInsets.top),
                $0.hStack(
                    $0.hGap(fixed: Constants.directionalEdgeInsets.leading),
                    self.iconView,
                    $0.hGap()
                ),
                $0.vGap(fixed: Constants.directionalEdgeInsets.bottom)
            )
        }
    }
    
    // MARK: Event handler
    
    func handleIconEmojiUpdate(_ iconEmoji: String?) {
        iconView.isHidden = iconEmoji.isNil
        iconEmoji.flatMap { iconView.configure(model: $0) }
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
