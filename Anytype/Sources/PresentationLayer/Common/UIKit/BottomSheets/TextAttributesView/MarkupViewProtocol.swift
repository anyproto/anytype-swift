import Foundation

protocol MarkupViewProtocol: AnyObject {
    
    func display(_ state: AllMarkupsState)
    func dismiss()
    
}
