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
    static var `default`: UIColor { UIColor.BackgroundNew.primary }
}

extension ComponentColor where T == Color {
    static var `default`: Color { Color.BackgroundNew.primary }
}

extension Color.Text {
    static var `default`: Color { Color.TextNew.primary }
}

extension UIColor.Text {
    static var `default`: UIColor { UIColor.TextNew.primary }
}

