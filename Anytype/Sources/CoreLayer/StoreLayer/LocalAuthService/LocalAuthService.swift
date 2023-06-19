import LocalAuthentication

protocol LocalAuthServiceProtocol {
    func auth(reason: String, completion: @escaping (Bool) -> Void)
}

final class LocalAuthService: LocalAuthServiceProtocol {
    func auth(reason: String, completion: @escaping (Bool) -> Void) {
        let permissionContext = LAContext()
        permissionContext.localizedCancelTitle = Loc.cancel

        var error: NSError?
        if permissionContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            permissionContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { didComplete, _ in
                completion(didComplete)
            }
        }
    }
}
