import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import MobileCoreServices


struct DividerBlockContentConfiguration: UIContentConfiguration, Hashable {
    let content: BlockContent.Divider
    
    // MARK:  - UIContentConfiguration
    func makeContentView() -> UIView & UIContentView {
        return DividerBlockContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> DividerBlockContentConfiguration {
        return self
    }
    
    // MARK: - Hashable
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.content == rhs.content
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(content)
    }
}
