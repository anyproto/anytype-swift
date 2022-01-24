import Foundation
import UIKit.UIViewController
import FloatingPanel

protocol RelationDetailsViewModelProtocol {
    
    var layoutPublisher: Published<FloatingPanelLayout>.Publisher { get }
        
    func makeViewController() -> UIViewController
    
}
