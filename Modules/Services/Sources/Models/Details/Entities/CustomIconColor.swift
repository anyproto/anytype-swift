import SwiftUI

public enum CustomIconColor: Int, CaseIterable, Sendable {
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
    
    public static let `default`: CustomIconColor = .gray
    
    public init?(iconOption: Int?) {
        guard let iconOption else {
            return nil
        }
        
        self.init(rawValue: iconOption - 1)
    }
}
