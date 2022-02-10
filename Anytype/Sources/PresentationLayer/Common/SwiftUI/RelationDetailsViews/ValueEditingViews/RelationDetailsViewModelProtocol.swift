import Foundation
import UIKit.UIViewController
import FloatingPanel

protocol RelationDetailsViewModelProtocol {
    
    var delegate: RelationDetailsViewModelDelegate? { get set }
    
    var floatingPanelLayout: FloatingPanelLayout { get }
            
    func makeViewController() -> UIViewController
    
}
