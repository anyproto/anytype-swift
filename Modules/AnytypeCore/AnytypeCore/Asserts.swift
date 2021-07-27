import UIKit
//import Firebase

public func anytypeAssertionFailure(_ message: String) {
    
//    #if DEBUG
//        showAlert(message)
//    #elseif RELEASE
//
//    #elseif ENTERPRISE
        showAlert(message)
//    #endif
}



private func showAlert(_ message: String) {
    let copyAction = UIAlertAction(title: "Copy assertion", style: .default) { _ in
        UIPasteboard.general.string = message
    }
    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
    
    let alert = UIAlertController(title: "Assertion", message: message, preferredStyle: .alert)
    alert.addAction(copyAction)
    alert.addAction(okAction)
    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
}
