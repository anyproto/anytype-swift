import UIKit

extension UIApplication {
    func hideKeyboard() {
        sendAction(
            #selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil
        )
    }
}
