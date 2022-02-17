import Foundation
import SwiftUI

enum AppIcon: CaseIterable {
    case oldSchool
    case gradient
    case art
    
    var description: String {
        switch self {
        case .gradient: return "Gradient".localized
        case .oldSchool: return "Old School".localized
        case .art: return "Art".localized
        }
    }
    
    var name: String? {
        switch self {
        case .gradient: return nil
        case .oldSchool: return "oldSchool"
        case .art: return "art"
        }
    }
    
    var preview: Image {
        switch self {
        case .gradient: return Image.appIcon
        case .oldSchool: return Image.oldSchoolAppIcon
        case .art: return Image.artAppIcon
        }
    }
}
