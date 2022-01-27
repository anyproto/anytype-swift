import Foundation
import UIKit.UIViewController
import FloatingPanel

protocol RelationDetailsViewModelProtocol {
    
    var closePopupAction: (() -> Void)? { get set }
    var layoutPublisher: Published<FloatingPanelLayout>.Publisher { get }
        
    func makeViewController() -> UIViewController
    
}
