import Foundation
import SwiftUI
import Combine
import os
import BlocksModels

class UnknownLabelViewModel: BaseBlockViewModel {
    override func makeContentConfiguration() -> UIContentConfiguration {
        var configuration = ContentConfiguration(block.blockModel.information)
        configuration.contextMenuHolder = self
        return configuration
    }
}
