import UIKit
import BlocksModels

struct BlockImageConfiguration: UIContentConfiguration, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.fileData == rhs.fileData
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileData)
    }
    
    let fileData: BlockFile
    let imageLoader: ImageLoader

    init(_ fileData: BlockFile, imageLoader: ImageLoader) {
        self.fileData = fileData
        self.imageLoader = imageLoader
    }
            
    func makeContentView() -> UIView & UIContentView {
        BlockImageContentView(configuration: self)
    }
    
    /// Hm, we could use state as from-user action channel.
    /// for example, if we have value "Checked"
    /// And we pressed something, we should do the following:
    /// We should pass value of state to a configuration.
    /// Next, configuration will send this value to a view model.
    /// Is it what we should use?
    func updated(for state: UIConfigurationState) -> BlockImageConfiguration {
        /// do something
        return self
    }
}
