import Foundation
import UIKit.UIViewController

protocol RelationDetailsViewModelProtocol {
    
    var heightPublisher: Published<CGFloat>.Publisher { get }
        
    func makeViewController() -> UIViewController
    
}
