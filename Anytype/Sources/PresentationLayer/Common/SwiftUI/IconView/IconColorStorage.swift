import Foundation
import SwiftUI
import AnytypeCore


final class IconColorStorage {
        
    static let allBackgroundColors = [
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
    
    static let allFontColors = [
        Color.Light.yellow,
        Color.Light.orange,
        Color.Light.red,
        Color.Light.pink,
        Color.Light.purple,
        Color.Light.blue,
        Color.Light.sky,
        Color.Light.teal,
        Color.Light.green,
        Color.Light.grey
    ]
    
    static func iconBackgroundColor(iconOption: Int) -> Color {
        let index = (iconOption - 1) % allBackgroundColors.count
        
        guard let color = allBackgroundColors[safe: index] else {
            anytypeAssertionFailure("Corrupted icon option", info: ["iconOption": "\(iconOption)"])
            return .Pure.sky
        }
        
        return color
    }
    
    static func iconTextColor(iconOption: Int) -> Color {
        let index = (iconOption - 1) % allFontColors.count
        
        guard let color = allFontColors[safe: index] else {
            anytypeAssertionFailure("Corrupted icon option", info: ["iconOption": "\(iconOption)"])
            return .Light.sky
        }
        
        return color
    }
    
    static func randomOption() -> Int {
        Int.random(in: 1...allBackgroundColors.count)
    }
}
