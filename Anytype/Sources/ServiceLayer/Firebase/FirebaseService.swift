import Firebase

final class FirebaseService {
    private let settingsDevFile = "GoogleService-Info-Dev"
    private let settingsReleaseFile = "GoogleService-Info-Release"
    private let devBundleIdentifier = "com.anytypeio.anytype.dev"
    
    func setup() {
        DispatchQueue.main.async {
            guard let bundleId = Bundle.main.bundleIdentifier else {
                assertionFailure("Can not get bundle id")
                return
            }
            let isDev = bundleId == self.devBundleIdentifier
            let file = isDev ? self.settingsDevFile : self.settingsReleaseFile
            guard let path = Bundle.main.path(forResource: file, ofType: "plist"),
                  let options = FirebaseOptions(contentsOfFile: path),
                  FirebaseApp.app().isNil else {
                return
            }
            FirebaseApp.configure(options: options)
        }
    }
}
