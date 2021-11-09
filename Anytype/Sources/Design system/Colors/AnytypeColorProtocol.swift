import Foundation

protocol AnytypeColorProtocol {
    associatedtype T
    
    // MARK: - Pure colors
    
    static var pureLemon: T { get }
    static var pureAmber: T { get }
    static var pureRed: T { get }
    static var purePink: T { get }
    static var purePurple: T { get }
    static var pureUltramarine: T { get }
    static var pureBlue: T { get }
    static var pureTeal: T { get }
    static var pureGreen: T { get }
    
    // MARK: - Dark colors
    
    static var darkLemon: T { get }
    static var darkAmber: T { get }
    static var darkRed: T { get }
    static var darkPink: T { get }
    static var darkPurple: T { get }
    static var darkUltramarine: T { get }
    static var darkBlue: T { get }
    static var darkTeal: T { get }
    static var darkGreen: T { get }
    static var darkColdGray: T { get }
    
    // MARK: - Light colors
    
    static var lightLemon: T { get }
    static var lightAmber: T { get }
    static var lightRed: T { get }
    static var lightPink: T { get }
    static var lightPurple: T { get }
    static var lightUltramarine: T { get }
    static var lightBlue: T { get }
    static var lightTeal: T { get }
    static var lightGreen: T { get }
    static var lightColdGray: T { get }
    
    // MARK: - Text colors
    
    static var textPrimary: T { get }
    static var textSecondary: T { get }
    static var textTertiary: T { get }
    
    // MARK: - Grayscale
    
    static var grayscaleWhite: T { get }
    static var grayscale90: T { get }
    static var grayscale70: T { get }
    static var grayscale50: T { get }
    static var grayscale30: T { get }
    static var grayscale10: T { get }
    
}
