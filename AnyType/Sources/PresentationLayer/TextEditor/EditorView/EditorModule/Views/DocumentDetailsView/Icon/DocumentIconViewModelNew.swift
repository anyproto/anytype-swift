//
//  DocumentIconViewModelNew.swift
//  Anytype
//
//  Created by Konstantin Mordan on 13.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit
import Combine

final class DocumentIconViewModelNew: DocumentDetailsChildViewModel {
    
    // MARK: - Private properties
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Publishers
    
    @Published var iconEmoji: String = ""
    
    // MARK: - Internal properties
    
    let detailsActiveModel: DetailsActiveModel
    
    // MARK: - Initializer
    
    init(detailsActiveModel: DetailsActiveModel) {
        self.detailsActiveModel = detailsActiveModel
        
        configureViewModel()
    }
    
    func makeView() -> UIView {
        DocumentIconView().configured(with: self)
    }
    
}

extension DocumentIconViewModelNew {
    
    var contextMenuActions: [UIAction] {
        UserAction.allCases.map { action in
            UIAction(
                title: action.title,
                image: action.icon
            ) { [weak self ] _ in
                self?.handle(action: action)
            }
        }
    }
    
}

// MARK: - UserAction

private extension DocumentIconViewModelNew {
    
    enum UserAction: CaseIterable {
        case select
        case random
        case upload
        case remove
    }
    
}

private extension DocumentIconViewModelNew.UserAction {
    
    var title: String {
        switch self {
        case .select:
            return "Choose emoji".localized
        case .random:
            return "Pick emoji randomly".localized
        case .upload:
            return "Upload photo".localized
        case .remove:
            return "Remove".localized
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .select:
            return UIImage(named: "Emoji/ContextMenu/choose")
        case .random:
            return UIImage(named: "Emoji/ContextMenu/random")
        case .upload:
            return UIImage(named: "Emoji/ContextMenu/upload")
        case .remove:
            return UIImage(named: "Emoji/ContextMenu/remove")
        }
    }
    
}

// MARK: - Private extension

private extension DocumentIconViewModelNew {
    
    func configureViewModel() {
        detailsActiveModel.wholeDetailsPublisher
            .map { $0.iconEmoji }
            .safelyUnwrapOptionals()
            .sink { [weak self] newIconEmoji in
                self?.iconEmoji = newIconEmoji.value
            }
            .store(in: &self.subscriptions)
    }
    
}

// MARK: - ActionMenu handler

private extension DocumentIconViewModelNew {
    
    func handle(action: UserAction) {
        switch action {
        case .select:
            handleSelectAction()
        case .random:
            handleRandomAction()
        case .remove:
            handleRemoveAction()
        case .upload:
            handleUploadAction()
        }
    }
    
    func handleSelectAction() {
    }
    
    func handleRandomAction() {
    }
    
    func handleRemoveAction() {
    }
    
    func handleUploadAction() {
    }
    
}
