import Foundation
import SwiftUI
import AnytypeCore


final class IconColorStorage {
        
    static let allColors = [
        Color.Pure.yellow,
        Color.Pure.orange,
        Color.Pure.red,
        Color.Pure.pink,
        Color.Pure.purple,
        Color.Pure.blue,
        Color.Pure.sky,
        Color.Pure.teal,
        Color.Pure.green,
        Color.Pure.grey
    ]
    
    static func iconColor(iconOption: Int) -> Color {
        let index = (iconOption - 1) % allColors.count
        
        guard let color = allColors[safe: index] else {
            anytypeAssertionFailure("Corrupted icon option", info: ["iconOption": "\(iconOption)"])
            return .Pure.sky
        }
        
        return color
    }
    
    static func randomOption() -> Int {
        Int.random(in: 1...allColors.count)
    }
}
