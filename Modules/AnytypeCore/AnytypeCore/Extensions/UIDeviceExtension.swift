import Foundation
import UIKit

public extension UIDevice {
    
    static var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    static var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
}
