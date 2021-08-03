import Foundation

protocol TextAttributesViewProtocol: AnyObject {
    
    func display(_ state: TextAttributesState)
    func hideView()
}
