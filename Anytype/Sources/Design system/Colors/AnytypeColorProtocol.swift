import Foundation
import UIKit
import SwiftUI

protocol ComponentColor {
    associatedtype T

    static var `default`: T { get }
    static var yellow: T { get }
    static var amber: T { get }
    static var red: T { get }
    static var pink: T { get }
    static var purple: T { get }
    static var blue: T { get }
    static var sky: T { get }
    static var teal: T { get }
    static var green: T { get }
    static var grey: T { get }
}

extension ComponentColor where T: UIColor {
    static var `default`: UIColor { UIColor.Background.primary }
}

extension ComponentColor where T == Color {
    static var `default`: Color { Color.Background.primary }
}

extension Color.Dark {
    static var `default`: Color { Color.Text.primary }
}

extension UIColor.Dark {
    static var `default`: UIColor { UIColor.Text.primary }
}

