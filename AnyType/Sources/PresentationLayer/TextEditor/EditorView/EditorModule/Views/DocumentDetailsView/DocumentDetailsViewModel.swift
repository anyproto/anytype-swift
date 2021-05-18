//
//  DocumentDetailsViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 13.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Combine
import BlocksModels

final class DocumentDetailsViewModel {
        
    var iconEmoji: String?
    
    // MARK: - Private variables
    
    private let detailsActiveModel: DetailsActiveModel
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    
    init(detailsActiveModel: DetailsActiveModel) {
        self.detailsActiveModel = detailsActiveModel
    }
    
}

// MARK: - Internal functions

extension DocumentDetailsViewModel {
    
    func handleIconUserAction(_ action: DocumentIconViewUserAction) {
        switch action {
        case .select:
            return
        case .random:
            return
        case .upload:
            return
        case .remove:
            handleRemoveIcon()
        }
    }
    
}

private extension DocumentDetailsViewModel {
    
    func handleRemoveIcon() {
        detailsActiveModel.update(
            details: DetailsContent.iconEmoji(
                Details.Information.Content.Emoji(value: "")
            )
        )?.sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished: return
                case let .failure(error):
                    assertionFailure("Emoji setDetails remove icon emoji error has occured.\n \(error)")
                }
            },
            receiveValue: { _ in
                return
            }
        )
        .store(in: &subscriptions)
    }
    
}
