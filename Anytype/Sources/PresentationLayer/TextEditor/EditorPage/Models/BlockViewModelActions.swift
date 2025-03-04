import Foundation
import UniformTypeIdentifiers
import Combine

@MainActor
protocol MediaBlockActionsProviderProtocol: AnyObject {
    func openImagePicker(blockId: String)
    func openVideoPicker(blockId: String)
    func openFilePicker(blockId: String)
    func openAudioPicker(blockId: String)
}

@MainActor
final class MediaBlockActionsProvider: MediaBlockActionsProviderProtocol {
    
    private var subscriptions = [AnyCancellable]()

    private let handler: any BlockActionHandlerProtocol
    private let router: any EditorRouterProtocol
    
    init(
        handler: some BlockActionHandlerProtocol,
        router: some EditorRouterProtocol
    ) {
        self.handler = handler
        self.router = router
    }
    
    func openImagePicker(blockId: String) {
        showMediaPicker(type: .images, blockId: blockId)
    }
    
    func openVideoPicker(blockId: String) {
        showMediaPicker(type: .videos, blockId: blockId)
    }
    
    func openFilePicker(blockId: String) {
        showFilePicker(blockId: blockId, types: [.item])
    }
    
    func openAudioPicker(blockId: String) {
        showFilePicker(blockId: blockId, types: [.audio])
    }
    
    // MARK: - Private
    
    private func showMediaPicker(type: MediaPickerContentType, blockId: String) {
        router.showImagePicker(contentType: type) { [weak self] itemProvider in
            guard let itemProvider = itemProvider else { return }
            
            self?.handler.uploadMediaFile(
                uploadingSource: .itemProvider(itemProvider),
                type: type,
                blockId: blockId
            )
        }
    }
    
    private func showFilePicker(blockId: String, types: [UTType]) {
        let model = AnytypePicker.ViewModel(types: types)
        model.$resultInformation.safelyUnwrapOptionals().sink { [weak self] result in
            self?.handler.uploadFileAt(localPath: result.filePath, blockId: blockId)
        }.store(in: &subscriptions)
        
        router.showFilePicker(model: model)
    }
}
