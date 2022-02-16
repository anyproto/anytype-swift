import Foundation

protocol AnytypePopupContentDelegate: NSObject {

    func didAskInvalidateLayout(_ animated: Bool)
    func didAskToClose()
    
}
