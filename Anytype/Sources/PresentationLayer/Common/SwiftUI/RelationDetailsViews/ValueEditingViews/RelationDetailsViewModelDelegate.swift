import Foundation

protocol RelationDetailsViewModelDelegate: NSObject {

    func didAskInvalidateLayout(_ animated: Bool)
    func didAskToClose()
    
}
