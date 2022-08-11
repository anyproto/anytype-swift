import AnytypeCore
import Firebase
import Logger

final class FirebaseNonFatalLogger: AssertionLoggerHandler {
    private let code = 1337
    
    func log(_ message: String, domain: String) {
        let userInfo = [ NSLocalizedDescriptionKey: message ]

        let error = NSError(domain: domain, code: code, userInfo: userInfo)
        Crashlytics.crashlytics().record(error: error)
    }
}
