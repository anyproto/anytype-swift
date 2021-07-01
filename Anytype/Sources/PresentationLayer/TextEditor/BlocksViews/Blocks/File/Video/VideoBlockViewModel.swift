import BlocksModels
import UIKit

final class VideoBlockViewModel: BlocksViewsBaseFileViewModel {
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        VideoBlockContentViewConfiguration(blockViewModel: self) ?? super.makeContentConfiguration()
    }
    
    override func handleReplace() {
        let model = MediaPickerViewModel(type: .videos) { [weak self] resultInformation in
            guard let resultInformation = resultInformation else { return }
            
            self?.sendFile(at: resultInformation.filePath)
        }
        
        router.showImagePicker(model: model)
    }
}
