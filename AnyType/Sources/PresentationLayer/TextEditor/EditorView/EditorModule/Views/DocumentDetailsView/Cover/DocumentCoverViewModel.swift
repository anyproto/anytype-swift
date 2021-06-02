import Combine
import UIKit
import BlocksModels

final class DocumentCoverViewModel {
    
    // MARK: - Private variables
    
    private let cover: DocumentCover
    
    private let fileService = BlockActionsServiceFile()
    private let detailsActiveModel: DetailsActiveModel
    private let userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private var onMediaPickerImageSelect: (() -> Void)?
    
    // MARK: - Initializer
    
    init(cover: DocumentCover,
         detailsActiveModel: DetailsActiveModel,
         userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>) {
        self.cover = cover
        self.detailsActiveModel = detailsActiveModel
        self.userActionSubject = userActionSubject
    }
    
}

// MARK: - Internal functions

extension DocumentCoverViewModel {
    
    func makeView() -> UIView {
        let view = DocumentCoverView().configured(with: cover)
        view.onCoverTap = { [weak self] in
            self?.showImagePicker()
        }
        
        onMediaPickerImageSelect = { [weak view] in
            view?.showLoader()
        }
        
        return view
    }
    
}

private extension DocumentCoverViewModel {
    
    // Sorry 🙏🏽
    typealias BlockUserAction = BlocksViews.UserAction
    
    func showImagePicker() {
        let model = MediaPicker.ViewModel(type: .images)
        model.onResultInformationObtain = { [weak self] resultInformation in
            guard let resultInformation = resultInformation else {
                // show error if needed
                return
            }
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.onMediaPickerImageSelect?()
            }
            
            self.uploadSelectedIconImage(at: resultInformation.filePath)
        }
        
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
    
    func uploadSelectedIconImage(at localPath: String) {
        fileService.uploadFile.action(
            url: "",
            localPath: localPath,
            type: .image,
            disableEncryption: false
        )
        .flatMap { [weak self] uploadedFile in
            self?.detailsActiveModel.update(
                details: [
                    .coverType: DetailsEntry(
                        value: CoverType.uploadedImage
                    ),
                    .coverId: DetailsEntry(
                        value: uploadedFile.hash
                    )
                ]
            ) ?? .empty()
        }
        .sinkWithDefaultCompletion("uploading image on \(self)") { _ in }
        .store(in: &self.subscriptions)
    }
    
}
