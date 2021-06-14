
import UIKit

final class VideoBlockViewModel: BlocksViews.File.Base.ViewModel {
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        VideoBlockContentViewConfiguration(blockViewModel: self) ?? super.makeContentConfiguration()
    }
    
    override func handleReplace() {
        let model: MediaPicker.ViewModel = .init(type: .videos)
        self.configureMediaPickerViewModel(model)
        self.send(userAction: .file(.shouldShowImagePicker(model)))
    }
}
