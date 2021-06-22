import BlocksModels
import UIKit

final class VideoBlockViewModel: BlocksViews.File.Base.ViewModel {
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        VideoBlockContentViewConfiguration(blockViewModel: self) ?? super.makeContentConfiguration()
    }
    
    override func handleReplace() {
        let model: MediaPicker.ViewModel = .init(type: .videos)
        configureMediaPickerViewModel(model)
        router?.showImagePicker(model: model)
    }
}
