import Foundation

protocol ComponentColor {
    associatedtype T

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
