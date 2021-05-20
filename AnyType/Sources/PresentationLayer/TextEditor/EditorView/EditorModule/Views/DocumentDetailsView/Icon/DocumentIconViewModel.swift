import Combine
import UIKit
import BlocksModels

final class DocumentIconViewModel {
    
    // MARK: - Private variables
    
    private let fileService = BlockActionsServiceFile()
    
    private var onImageSelect: ((String?) -> Void)?

    
    private let documentIcon: DocumentIcon?
    private let detailsActiveModel: DetailsActiveModel
    private let userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    
    init(documentIcon: DocumentIcon?,
         detailsActiveModel: DetailsActiveModel,
         userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>) {
        self.documentIcon = documentIcon
        self.detailsActiveModel = detailsActiveModel
        self.userActionSubject = userActionSubject
    }
    
}

// MARK: - Internal functions

extension DocumentIconViewModel {
    
    func makeView() -> UIView? {
        switch documentIcon {
        case let .emoji(iconEmoji):
            return makeIconEmojiView(with: iconEmoji)
        case let .image(imageId):
            return makeIconImageView(with: imageId)
        case .none:
            return nil
        }
    }
    
}

// MARK: - Private extension

private extension DocumentIconViewModel {
    
    func makeIconEmojiView(with emoji: IconEmoji) -> UIView {
        let view = DocumentIconEmojiView().configured(with: emoji)
        view.enableMenuInteraction { [weak self] userAction in
            self?.handleIconUserAction(userAction)
        }
        
        return view
    }
    
    func makeIconImageView(with imageId: String) -> UIView {
        let view = DocumentIconImageView().configured(with: imageId)
        view.enableMenuInteraction { [weak self] userAction in
            self?.handleIconUserAction(userAction)
        }
        
        onImageSelect = {
            view.showLoaderWithImage(at: $0)
        }
        
        return view
    }
    
}

// MARK: - Actions handler

private extension DocumentIconViewModel {
    
    // Sorry 🙏🏽
    typealias BlockUserAction = BlocksViews.UserAction
    
    func handleIconUserAction(_ action: DocumentIconViewUserAction) {
        switch action {
        case .select:
            showEmojiPicker()
        case .random:
            setRandomEmoji()
        case .upload:
            showImagePicker()
        case .remove:
            removeIcon()
        }
    }
    
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
    
    func showImagePicker() {
        let model = CommonViews.Pickers.Picker.ViewModel(type: .images)
        subscribeForPickedImage(in: model)
        
        userActionSubject.send(
            BlockUserAction.specific(
                BlockUserAction.SpecificAction.file(
                    BlockUserAction.File.FileAction.shouldShowImagePicker(
                        .init(model: model)
                    )
                )
            )
        )
    }
    
    func subscribeForPickedImage(in pickerViewModel: CommonViews.Pickers.Picker.ViewModel) {
        pickerViewModel.$resultInformation
            .safelyUnwrapOptionals()
            .reciveOnMain()
            .sink { [weak self] filePickerResultInformation in
                self?.onImageSelect?(filePickerResultInformation.filePath)
            }.store(in: &self.subscriptions)
        
        pickerViewModel.$resultInformation
            .safelyUnwrapOptionals()
            .notableError()
            .flatMap { [weak self] selectedFile in
                self?.fileService.uploadFile.action(
                    url: "",
                    localPath: selectedFile.filePath,
                    type: .image,
                    disableEncryption: false
                ) ?? .empty()
            }
            .flatMap { [weak self] uploadFile in
                self?.detailsActiveModel.update(
                    details: [
                        DetailsContent.iconEmoji(
                            Details.Information.Content.Emoji(value: "")
                        ),
                        DetailsContent.iconImage(
                            Details.Information.Content.ImageId(value: uploadFile.hash)
                        )
                    ]
                ) ?? .empty()
            }
            .sink(
                receiveCompletion: { value in
                    switch value {
                    case .finished: break
                    case let .failure(value):
                        assertionFailure("uploading image error \(value) on \(self)")
                    }
                }
            ) { _ in }
            .store(in: &self.subscriptions)
    }
    
    func setRandomEmoji() {
        let emoji = EmojiPicker.Manager().random()
        
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
