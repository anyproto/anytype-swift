import AnytypeCore
import Firebase

final class FirebaseNonFatalLogger: MessageLogger {
    private let code = 1337
    
    func log(_ message: String, domain: ErrorDomain) {
        let userInfo = [ NSLocalizedDescriptionKey: message ]

        let error = NSError(domain: domain.rawValue, code: code, userInfo: userInfo)
        Crashlytics.crashlytics().record(error: error)
    }
}
