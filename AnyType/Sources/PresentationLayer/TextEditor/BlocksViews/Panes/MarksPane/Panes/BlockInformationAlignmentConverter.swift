import Foundation
import UIKit
import Combine
import SwiftUI
import os
import BlocksModels


enum BlockInformationAlignmentConverter {
    static func convert(_ alignment: NSTextAlignment) -> BlockInformationAlignment? {
        let result = self.state(alignment)
        if result.isNil {
            assertionFailure("We receive uncommon result. We should map it to correct attribute != nil. Style is: \(alignment)")
        }
        return result
    }
    
    private static func state(_ style: NSTextAlignment) -> BlockInformationAlignment? {
        switch style {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .justified: return nil
        case .natural: return nil
        @unknown default: return nil
        }
    }
}
