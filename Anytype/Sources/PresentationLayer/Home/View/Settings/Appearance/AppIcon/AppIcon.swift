import Foundation
import SwiftUI

enum AppIcon: CaseIterable {
    case oldSchool
    case gradient
    case art
    
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
