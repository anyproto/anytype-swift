import Foundation
import SwiftUI
import AnytypeCore


final class IconColorStorage {
        
    static let allColors = [
        Color.System.yellow,
        Color.System.orange,
        Color.System.red,
        Color.System.pink,
        Color.System.purple,
        Color.System.blue,
        Color.System.sky,
        Color.System.teal,
        Color.System.green,
        Color.System.grey
    ]
    
    static func iconColor(iconOption: Int) -> Color {
        let index = (iconOption - 1) % allColors.count
        
        guard let color = allColors[safe: index] else {
            anytypeAssertionFailure("Corrupted icon option", info: ["iconOption": "\(iconOption)"])
            return .System.sky
        }
        
        return color
    }
    
    static func randomOption() -> Int {
        Int.random(in: 1...allColors.count)
    }
}
