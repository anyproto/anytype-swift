import Foundation
import SwiftUI
import BlocksModels
import MobileCoreServices

struct DividerBlockContentConfiguration: BlockConfigurationProtocol, Hashable {
    let content: BlockDivider
    var currentConfigurationState: UICellConfigurationState?
    
    // MARK:  - UIContentConfiguration
    func makeContentView() -> UIView & UIContentView {
        return DividerBlockContentView(configuration: self)
    }
}
