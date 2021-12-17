import SwiftUI

// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Android---main---draft?node-id=3681%3A1219
extension Color: AnytypeColorProtocol {    
    // MARK: - Mapping
    static let buttonPrimary = pureAmber
    static let buttonPrimartText = white
    
    static let buttonSecondary = backgroundPrimary
    static let buttonSecondaryBorder = stroke
    static let buttonSecondaryText = textPrimary
    
    static let buttonActive = Color.grayscale50
}
