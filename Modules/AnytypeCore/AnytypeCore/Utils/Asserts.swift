import UIKit

public func anytypeAssertionFailure(
    _ message: String,
    file: StaticString = #file,
    line: UInt = #line
) {
    #if RELEASE
        logNonFatal(message)
    #elseif ENTERPRISE
        if FeatureFlags.showAlertOnAssert {
            showAssertionAlert(message)
        }
    #elseif DEBUG
//        assertionFailure(message, file: file, line: line)
    #endif
}

public func anytypeAssert(
    _ condition: @autoclosure () -> Bool,
    _ message: String,
    file: StaticString = #file,
    line: UInt = #line
) {
    if condition() != true {
        anytypeAssertionFailure(message, file: file, line: line)
    }
}

// MARK:- Private
private func showAssertionAlert(_ message: String) {
    
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

    
    DispatchQueue.main.async {
        keyWindow.rootViewController?.topPresentedController.present(alert, animated: true, completion: nil)
    }
}

private func logNonFatal(_ message: String) {
    AssertionLogger.shared?.log(message)
}
