import Firebase

final class FirebaseService {
    private let settingsDevFile = "GoogleService-Info-Dev"
    private let settingsReleaseFile = "GoogleService-Info-Release"
    
    func setup() {
        DispatchQueue.main.async {
            let bundleId = Bundle.main.bundleIdentifier ?? ""
            let file = bundleId.hasSuffix("dev") ? self.settingsDevFile : self.settingsReleaseFile
            guard let path = Bundle.main.path(forResource: file, ofType: "plist"),
                  let options = FirebaseOptions(contentsOfFile: path),
                  FirebaseApp.app().isNil else {
                return
            }
            FirebaseApp.configure(options: options)
        }
    }
}
