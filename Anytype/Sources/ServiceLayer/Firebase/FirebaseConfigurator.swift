import Firebase

final class FirebaseConfigurator: AppConfiguratorProtocol {
    #if RELEASE
    private let settingsFile = "GoogleService-Info-Release"
    #else
    private let settingsFile = "GoogleService-Info-Dev"
    #endif
    
    func configure() {
        guard let path = Bundle.main.path(forResource: settingsFile, ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) else {
            return
        }
        FirebaseApp.configure(options: options)
    }
}
