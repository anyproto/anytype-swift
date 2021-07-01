import UIKit
import BlocksModels
import Combine

final class BlockImageViewModel: BlocksViewsBaseFileViewModel {
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        return BlockImageConfiguration(block.blockModel.information)
    }
    
    override func handleReplace() {
        let model = MediaPicker.ViewModel(type: .images)
        router.showImagePicker(model: model)
        
        model.onResultInformationObtain = { [weak self] resultInformation in
            guard let resultInformation = resultInformation else { return }
            
            self?.sendFile(at: resultInformation.filePath)
        }
    }
}
