import BlocksModels
import UIKit

final class VideoBlockViewModel: BlocksViewsBaseFileViewModel {
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        VideoBlockContentViewConfiguration(blockViewModel: self) ?? super.makeContentConfiguration()
    }
    
    override func handleReplace() {
        let model: MediaPicker.ViewModel = .init(type: .videos)
        router.showImagePicker(model: model)
        
        model.onResultInformationObtain = { [weak self] resultInformation in
            guard let resultInformation = resultInformation else { return }
            
            self?.sendFile(at: resultInformation.filePath)
        }
    }
}
