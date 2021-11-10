import Foundation
import SwiftUI
import BlocksModels
import MobileCoreServices

struct DividerBlockContentConfiguration: AnytypeBlockContentConfigurationProtocol, Hashable {
    let content: BlockDivider
    var currentConfigurationState: UICellConfigurationState?
    
    // MARK:  - UIContentConfiguration
    func makeContentView() -> UIView & UIContentView {
        return DividerBlockContentView(configuration: self)
    }
}
