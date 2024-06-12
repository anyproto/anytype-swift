import Foundation

public enum MiddlewareColor: String, CaseIterable, Sendable {
    case `default`, grey, yellow, orange, red, pink, purple, blue, ice, teal, lime
    
    public static var allCasesWithoutDefault = MiddlewareColor.allCases.filter { $0 != .default }
}
