import UIKit

public func anytypeAssertionFailure(_ message: String) {
    #if RELEASE
        logNonFatal(message)
    #elseif ENTERPRISE
    if FeatureFlags.showAlertOnAssert {
        showAlert(message)
    }
    #elseif DEBUG
        assertionFailure(message)
    #endif
}

private func logNonFatal(_ message: String) {
    AssertionLogger.shared?.log(message)
}

private func showAlert(_ message: String) {
    guard let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
        return
    }
    
    let copyAction = UIAlertAction(title: "Copy assertion", style: .default) { _ in
        UIPasteboard.general.string = message
    }
    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
    
    let alert = UIAlertController(title: "Assertion", message: message, preferredStyle: .alert)
    alert.addAction(copyAction)
    alert.addAction(okAction)
    
    keyWindow.rootViewController?.present(alert, animated: true, completion: nil)
}
