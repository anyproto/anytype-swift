import Foundation
import Firebase
import os

private extension Logging.Categories {
    static let servicesFirebaseService: Self = "ServicesLayer.FirebaseService"
}

class FirebaseService {
    private let settingsFile = "GoogleService-Info"
    
    func setup() {
        let path = Bundle(for: Self.self).path(forResource: self.settingsFile, ofType: "plist")
        if let path = path, let options = FirebaseOptions.init(contentsOfFile: path) {
            DispatchQueue.main.async {
                FirebaseApp.configure(options: options)
            }
        }
        else {
            let logger = Logging.createLogger(category: .servicesFirebaseService)
            os_log(.error, log: logger, "Can't create options with file at path: %@", String(describing: self.settingsFile))
        }
    }
}
