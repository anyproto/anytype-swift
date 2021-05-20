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
        
    var documentIcon: DocumentIcon?
    
    // MARK: - Private variables
    
    private let detailsActiveModel: DetailsActiveModel
    private let userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    
    init(detailsActiveModel: DetailsActiveModel,
         userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>) {
        self.detailsActiveModel = detailsActiveModel
        self.userActionSubject = userActionSubject
    }
    
}

// MARK: - Internal functions

extension DocumentDetailsViewModel {
    
    func handleIconUserAction(_ action: DocumentIconViewUserAction) {
        switch action {
        case .select:
            showEmojiPicker()
        case .random:
            setRandomEmoji()
        case .upload:
            return
        case .remove:
            removeIcon()
        }
    }
    
}

private extension DocumentDetailsViewModel {
    
    // Sorry 🙏🏽
    typealias BlockUserAction = BlocksViews.UserAction
    
    func showEmojiPicker() {
        let model = EmojiPicker.ViewModel()
        
        model.$selectedEmoji
            .safelyUnwrapOptionals()
            .sink { [weak self] emoji in
                self?.updateDetails(
                    [
                        DetailsContent.iconEmoji(
                            Details.Information.Content.Emoji(value: emoji.unicode)
                        ),
                        DetailsContent.iconImage(
                            Details.Information.Content.ImageId(value: "")
                        )
                    ]
                )
            }
            .store(in: &subscriptions)
        
        userActionSubject.send(
            BlockUserAction.specific(
                BlockUserAction.SpecificAction.page(
                    BlockUserAction.Page.UserAction.emoji(
                        BlockUserAction.Page.UserAction.EmojiAction.shouldShowEmojiPicker(model)
                    )
                )
            )
        )
    }
    
    func setRandomEmoji() {
        let emoji = EmojiPicker.Manager().random()
        
        // TODO: - Implement removing loaded image
        updateDetails(
            [
                DetailsContent.iconEmoji(
                    Details.Information.Content.Emoji(value: emoji.unicode)
                ),
                DetailsContent.iconImage(
                    Details.Information.Content.ImageId(value: "")
                )
            ]
        )
    }
    
    func removeIcon() {
        updateDetails(
            [
                DetailsContent.iconEmoji(
                    Details.Information.Content.Emoji(value: "")
                ),
                DetailsContent.iconImage(
                    Details.Information.Content.ImageId(value: "")
                )
            ]
        )
    }
    
    func updateDetails(_ details: [DetailsContent]) {
        detailsActiveModel.update(
            details: details
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
