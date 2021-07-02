import UIKit
import BlocksModels
import Combine

final class BlockFileViewModel: BlocksViewsBaseFileViewModel {
    
    private var subscription: AnyCancellable?
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        return BlockFileConfiguration(block.blockModel.information)
    }
    
    override func handleReplace() {
        let model: CommonViews.Pickers.File.Picker.ViewModel = .init()
        router.showFilePicker(model: model)
        
        subscription = model.$resultInformation.safelyUnwrapOptionals().sink { [weak self] (value) in
            self?.sendFile(at: value.filePath)
        }
    }
}
