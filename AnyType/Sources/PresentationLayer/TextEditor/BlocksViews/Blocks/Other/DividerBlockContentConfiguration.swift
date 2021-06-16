import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import MobileCoreServices


struct DividerBlockContentConfiguration: UIContentConfiguration, Hashable {
    let information: BlockInformation
    
    init(_ information: BlockInformation) {
        if case .divider = information.content {
            assertionFailure("Can't create content configuration for content: \(information.content)")
        }
        
        self.information = information
    }
            
    // MARK:  - UIContentConfiguration
    func makeContentView() -> UIView & UIContentView {
        return DividerBlockContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> DividerBlockContentConfiguration {
        return self
    }
    
    // MARK: - Hashable
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.information == rhs.information
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.information)
    }
}
