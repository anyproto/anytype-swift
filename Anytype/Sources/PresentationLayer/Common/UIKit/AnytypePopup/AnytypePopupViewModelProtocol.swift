import Foundation
import UIKit.UIViewController
import FloatingPanel

protocol AnytypePopupViewModelProtocol {
    
    var popupLayout: FloatingPanelLayout { get }
    
    func setContentDelegate(_ сontentDelegate: AnytypePopupContentDelegate)
    
    func makeContentView() -> UIViewController
    
}
