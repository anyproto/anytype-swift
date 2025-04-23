import SwiftUI

public extension Color {
    
    init(hex: String, opacity: Double = 1) {
        let chars = Array(hex.dropFirst())
        
        self.init(
            red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
            green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
            blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
            opacity: opacity
        )
    }
    
    
    init(light: Color, dark: Color) {
        let color = UIColor(dynamicProvider: {
            switch $0.userInterfaceStyle {
            case .light, .unspecified:
                return UIColor(light)
            case .dark:
                return UIColor(dark)
            @unknown default:
                return UIColor(light)
            }
        })
        self.init(color)
    }
}
