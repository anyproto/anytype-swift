
import UIKit

final class VideoBlockViewModel: BlocksViews.File.Base.ViewModel {
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        VideoBlockContentViewConfiguration(blockViewModel: self) ?? super.makeContentConfiguration()
    }
    
    override func handleReplace() {
        let model: CommonViews.Pickers.Picker.ViewModel = .init(type: .videos)
        self.configureListening(model)
        self.send(userAction: .specific(.file(.shouldShowImagePicker(.init(model: model)))))
    }
}
