import SwiftUI

public enum CustomIconColor: Int, CaseIterable, Sendable, Codable, Identifiable {
    case gray
    case yellow
    case orange
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
    
    public var id: Int { rawValue }
    
    public static let `default`: CustomIconColor = .gray
    
    public init?(iconOption: Int?) {
        guard let iconOption else {
            return nil
        }
        
        self.init(rawValue: iconOption - 1)
    }
}
