import LocalAuthentication

protocol LocalAuthServiceProtocol: Sendable {
    func auth(reason: String) async throws
}

enum LocalAuthServiceError: Error {
    case commonError
}

final class LocalAuthService: LocalAuthServiceProtocol, Sendable {
    func auth(reason: String) async throws {
        let permissionContext = LAContext()
        permissionContext.localizedCancelTitle = Loc.cancel
        var error: NSError?
        
        guard permissionContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            throw LocalAuthServiceError.commonError
        }
        
        let result = try await permissionContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        if !result {
            throw LocalAuthServiceError.commonError
        }
    }
}
