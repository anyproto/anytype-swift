import AnytypeCore
import Firebase

final class FirebaseNonFatalLogger: AnytypeCore.Logger {
    private let domain = "AnytypeNonfatalDefaultErrorDomain"
    private let code = 1337
    
    func log(_ message: String) {
        let userInfo = [ NSLocalizedDescriptionKey: message ]

        let error = NSError(
            domain: domain,
            code: code,
            userInfo: userInfo
        )
        Crashlytics.crashlytics().record(error: error)
    }
}
