import LocalAuthentication

protocol LocalAuthServiceProtocol: Sendable {
    func auth(reason: String) async throws
}

enum LocalAuthServiceError: Error {
    case commonError
    case passcodeNotSet
}

final class LocalAuthService: LocalAuthServiceProtocol, Sendable {
    func auth(reason: String) async throws {
        let permissionContext = LAContext()
        permissionContext.localizedCancelTitle = Loc.cancel
        var error: NSError?
        
        if permissionContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let result = try await permissionContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            if !result {
                throw LocalAuthServiceError.commonError
            }
        } else if let laError = error as? LAError, laError.code == .passcodeNotSet {
            throw LocalAuthServiceError.passcodeNotSet
        } else {
            throw LocalAuthServiceError.commonError
        }
    }
}
