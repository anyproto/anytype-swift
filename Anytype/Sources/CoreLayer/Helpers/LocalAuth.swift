import LocalAuthentication

class LocalAuth {
    static func auth(reason: String, completion: @escaping (Bool) -> Void) {
        let permissionContext = LAContext()
        permissionContext.localizedCancelTitle = "Cancel".localized

        var error: NSError?
        if permissionContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            permissionContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { didComplete, _ in
                completion(didComplete)
            }
        }
    }
}
