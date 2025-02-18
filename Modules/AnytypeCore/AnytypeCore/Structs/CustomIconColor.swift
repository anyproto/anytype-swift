import SwiftUI

public enum CustomIconColor: Int, CaseIterable {
    case gray
    case yellow
    case amber
    case red
    case pink
    case purple
    case blue
    case sky
    case teal
    case green
    
    public var iconOption: Int {
        rawValue + 1
    }
}
