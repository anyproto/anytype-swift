import Foundation

protocol MarkupViewProtocol: AnyObject {
    
    func display(_ state: AllMarkupState)
    func hideView()
}
