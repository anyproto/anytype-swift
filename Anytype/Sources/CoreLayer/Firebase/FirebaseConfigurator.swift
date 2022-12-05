import Firebase
import AnytypeCore
import Logger

final class FirebaseConfigurator: AppConfiguratorProtocol {
    #if DEBUG
    private let settingsFile = "GoogleService-Info-Dev"
    #else
    private let settingsFile = "GoogleService-Info"
    #endif
    
    func configure() {        
        guard let path = Bundle.main.path(forResource: settingsFile, ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) else {
            return
        }
        FirebaseApp.configure(options: options)
        
        #if !DEBUG
        AssertionLogger.shared.handler = FirebaseNonFatalLogger()
        #endif
    }
}
