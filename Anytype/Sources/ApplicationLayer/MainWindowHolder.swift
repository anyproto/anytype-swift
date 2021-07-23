import UIKit
import SwiftUI

protocol MainWindowHolder {
    
    var rootNavigationController: UINavigationController { get }
    
    func startNewRootView<ViewType: View>(_ view: ViewType)
    
    func configureNavigationBarWithOpaqueBackground()
    func configureNavigationBarWithTransparentBackground()
    
    func configureMiddlewareConfiguration()

}
