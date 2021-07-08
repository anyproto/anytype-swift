import Foundation
import UIKit
import os

public enum MiddlewareColor: CaseIterable {
    case `default`, grey, yellow, orange, red, pink, purple, blue, ice, teal, lime

    public init?(name: String) {
        guard let value = Self.allCases.first(where: {$0.name() == name}) else {
            return nil
        }
        self = value
    }

    public func name() -> String {
        switch self {
        case .default: return "default"
        case .grey: return "grey"
        case .yellow: return "yellow"
        case .orange: return "orange"
        case .red: return "red"
        case .pink: return "pink"
        case .purple: return "purple"
        case .blue: return "blue"
        case .ice: return "ice"
        case .teal: return "teal"
        case .lime: return "lime"
        }
    }
}
