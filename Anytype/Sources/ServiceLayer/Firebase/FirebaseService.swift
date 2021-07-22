import Firebase

final class FirebaseService: AppConfiguratorProtocol {
    private let settingsDevFile = "GoogleService-Info-Dev"
    private let settingsReleaseFile = "GoogleService-Info-Release"
    private let devBundleIdentifier = "com.anytypeio.anytype.dev"
    
    func configure() {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            assertionFailure("Can not get bundle id")
            return
        }
        let isDev = bundleId == self.devBundleIdentifier
        let file = isDev ? self.settingsDevFile : self.settingsReleaseFile
        guard let path = Bundle.main.path(forResource: file, ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) else {
            return
        }
        FirebaseApp.configure(options: options)
    }
}
