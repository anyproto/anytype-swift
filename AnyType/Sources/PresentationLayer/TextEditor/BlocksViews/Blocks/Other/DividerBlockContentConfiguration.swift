import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import MobileCoreServices


private extension Logging.Categories {
    static let blocksViewsNewOtherDivider: Self = "BlocksViews.Other.Divider"
}
    
/// As soon as we have builder in this type ( makeContentView )
/// We could map all states ( for example, image has several states ) to several different ContentViews.
///
struct DividerBlockContentConfiguration: UIContentConfiguration, Hashable {
    typealias Information = Block.Information.InformationModel
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.information == rhs.information
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.information)
    }
    
    var information: Information
    weak var contextMenuHolder: DividerBlockViewModel?
    
    init(_ information: Information) {
        /// We should warn if we have incorrect content type (?)
        /// Don't know :(
        /// Think about failable initializer
        
        switch information.content {
        case .divider: break
        default:
            let logger = Logging.createLogger(category: .blocksViewsNewOtherDivider)
            os_log(.error, log: logger, "Can't create content configuration for content: %@", String(describing: information.content))
            break
        }
        
        self.information = .init(information: information)
    }
            
    /// UIContentConfiguration
    func makeContentView() -> UIView & UIContentView {
        let view = DividerBlockContentView(configuration: self)
//            self.contextMenuHolder?.addContextMenu(view)
        return view
    }
    
    /// Hm, we could use state as from-user action channel.
    /// for example, if we have value "Checked"
    /// And we pressed something, we should do the following:
    /// We should pass value of state to a configuration.
    /// Next, configuration will send this value to a view model.
    /// Is it what we should use?
    func updated(for state: UIConfigurationState) -> DividerBlockContentConfiguration {
        /// do something
        return self
    }
}
