
import UIKit

final class VideoBlockViewModel: BlocksViews.New.File.Base.ViewModel {
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        VideoBlockContentViewConfiguration(blockViewModel: self) ?? super.makeContentConfiguration()
    }
    
    override func handle(event: BlocksViews.UserEvent) {
        switch event {
        case .didSelectRowInTableView:
            if self.state == .uploading {
                return
            }
            self.handleReplace()
        }
    }
    
    override func handleReplace() {
        let model: CommonViews.Pickers.Picker.ViewModel = .init(type: .videos)
        self.configureListening(model)
        self.send(userAction: .specific(.file(.shouldShowImagePicker(.init(model: model)))))
    }
}
