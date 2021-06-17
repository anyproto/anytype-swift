import Foundation
import Firebase
import os

class FirebaseService {
    private let settingsFile = "GoogleService-Info"
    
    func setup() {
        let path = Bundle(for: Self.self).path(forResource: self.settingsFile, ofType: "plist")
        if let path = path, let options = FirebaseOptions.init(contentsOfFile: path) {
            DispatchQueue.main.async {
                if FirebaseApp.app().isNil {
                    FirebaseApp.configure(options: options)
                }
            }
        }
        else {
            assertionFailure("Can't create options with file at path: \(settingsFile)")
        }
    }
}
